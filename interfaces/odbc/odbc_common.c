/*
 * This file is released under the terms of the Artistic License.  Please see
 * the file LICENSE, included in this package, for details.
 *
 * Copyright (C) 2002 Mark Wong & Jenny Zhang &
 *                    Open Source Development Labs, Inc.
 *
 * 11 June 2002
 */

#include <pthread.h>
#include <stdio.h>

#include "odbc_common.h"

SQLHENV henv = SQL_NULL_HENV;
pthread_mutex_t db_source_mutex = PTHREAD_MUTEX_INITIALIZER;

SQLCHAR servername[32];
SQLCHAR username[32];
SQLCHAR authentication[32];

int check_odbc_rc(SQLSMALLINT handle_type, SQLHANDLE handle, SQLRETURN rc)
{
	
	if (rc == SQL_SUCCESS) {
		return OK;
	} else if (rc == SQL_SUCCESS_WITH_INFO) {
		LOG_ERROR_MESSAGE("SQL_SUCCESS_WITH_INFO");
	} else if (rc == SQL_NEED_DATA) {
		LOG_ERROR_MESSAGE("SQL_NEED_DATA");
	} else if (rc == SQL_STILL_EXECUTING) {
		LOG_ERROR_MESSAGE("SQL_STILL_EXECUTING");
	} else if (rc == SQL_ERROR) {
		return ERROR;
	} else if (rc == SQL_NO_DATA) {
		LOG_ERROR_MESSAGE("SQL_NO_DATA");
	} else if (rc == SQL_INVALID_HANDLE) {
		LOG_ERROR_MESSAGE("SQL_INVALID_HANDLE");
	}
	
	return OK;
}

/* Print out all errors messages generated to the error log file. */
int log_odbc_error(char *filename, int line, SQLSMALLINT handle_type,
	SQLHANDLE handle)
{
	SQLCHAR sqlstate[5];
	SQLCHAR message[256];
	SQLSMALLINT i;
	char msg[1024];

	i = 1;
	while (SQLGetDiagRec(handle_type, handle, i, sqlstate,
		NULL, message, sizeof(message), NULL) == SQL_SUCCESS) {
		sprintf(msg, "[%d] sqlstate %s : %s", i, sqlstate, message);
		log_error_message(filename, line, msg);
		++i;
	}
	return OK;
}

int commit_transaction(struct db_context_t *dbc)
{
	int i;

	i = SQLEndTran(SQL_HANDLE_DBC, dbc->hdbc, SQL_COMMIT);
	if (i != SQL_SUCCESS && i != SQL_SUCCESS_WITH_INFO) {
		LOG_ODBC_ERROR(SQL_HANDLE_STMT, dbc->hstmt);
		return ERROR;
	}
	return OK;
}

/* Open an ODBC connection to the database. */
int _connect_to_db(struct db_context_t *odbcc)
{
	SQLRETURN rc;

	/* Allocate connection handles. */
	pthread_mutex_lock(&db_source_mutex);
	rc = SQLAllocHandle(SQL_HANDLE_DBC, henv, &odbcc->hdbc);
	if (rc != SQL_SUCCESS && rc != SQL_SUCCESS_WITH_INFO) {
		LOG_ODBC_ERROR(SQL_HANDLE_DBC, odbcc->hdbc);
		SQLFreeHandle(SQL_HANDLE_DBC, odbcc->hdbc);
		return ERROR;
	}

	/* Open connection to the database. */
	rc = SQLConnect(odbcc->hdbc, servername, SQL_NTS,
		username, SQL_NTS, authentication, SQL_NTS);
	if (rc != SQL_SUCCESS && rc != SQL_SUCCESS_WITH_INFO) {
		LOG_ODBC_ERROR(SQL_HANDLE_DBC, odbcc->hdbc);
		SQLFreeHandle(SQL_HANDLE_DBC, odbcc->hdbc);
		return ERROR;
	}

	rc = SQLSetConnectAttr(odbcc->hdbc, SQL_ATTR_AUTOCOMMIT,
		SQL_AUTOCOMMIT_OFF, 0);
	if (rc != SQL_SUCCESS && rc != SQL_SUCCESS_WITH_INFO) {
	        LOG_ODBC_ERROR(SQL_HANDLE_STMT, odbcc->hstmt);
	        return ERROR;
	}

	rc = SQLSetConnectAttr(odbcc->hdbc, SQL_ATTR_TXN_ISOLATION,
		SQL_TXN_REPEATABLE_READ, 0);
	if (rc != SQL_SUCCESS && rc != SQL_SUCCESS_WITH_INFO) {
	        LOG_ODBC_ERROR(SQL_HANDLE_STMT, odbcc->hstmt);
	        return ERROR;
	}

	/* allocate statement handle */
	rc = SQLAllocHandle(SQL_HANDLE_STMT, odbcc->hdbc, &odbcc->hstmt);
	if (rc != SQL_SUCCESS && rc != SQL_SUCCESS_WITH_INFO) {
	        LOG_ODBC_ERROR(SQL_HANDLE_STMT, odbcc->hstmt);
	        return ERROR;
	}
	pthread_mutex_unlock(&db_source_mutex);

	return OK;
}

/*
 * Disconnect from the database and free the connection handle.
 * Note that we create the environment handle in odbc_connect() but
 * we don't touch it here.
 */
int odbc_disconnect(struct db_context_t *odbcc)
{
	SQLRETURN rc;

	pthread_mutex_lock(&db_source_mutex);
	rc = SQLDisconnect(odbcc->hdbc);
	if (rc != SQL_SUCCESS && rc != SQL_SUCCESS_WITH_INFO) {
		LOG_ODBC_ERROR(SQL_HANDLE_DBC, odbcc->hdbc);
		return ERROR;
	}
	rc = SQLFreeHandle(SQL_HANDLE_DBC, odbcc->hdbc);
	if (rc != SQL_SUCCESS && rc != SQL_SUCCESS_WITH_INFO) {
		LOG_ODBC_ERROR(SQL_HANDLE_DBC, odbcc->hdbc);
		return ERROR;
	}
	rc = SQLFreeHandle(SQL_HANDLE_STMT, odbcc->hstmt);
	if (rc != SQL_SUCCESS) {
	        LOG_ODBC_ERROR(SQL_HANDLE_STMT, odbcc->hstmt);
	        return ERROR;
	}
	pthread_mutex_unlock(&db_source_mutex);
	return OK;
}

/* Initialize ODBC environment handle and the database connect string. */
int _db_init(char *sname, char *uname, char *auth)
{
	SQLRETURN rc;

	/* Initialized the environment handle. */
	rc = SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &henv);
	if (rc != SQL_SUCCESS && rc != SQL_SUCCESS_WITH_INFO) {
		LOG_ERROR_MESSAGE("alloc env handle failed");
		return ERROR;
	}
	rc = SQLSetEnvAttr(henv, SQL_ATTR_ODBC_VERSION, (void *) SQL_OV_ODBC3,
		0);
	if (rc != SQL_SUCCESS && rc != SQL_SUCCESS_WITH_INFO) {
		SQLFreeHandle(SQL_HANDLE_ENV, henv);
		return ERROR;
	}

	/* Set the database connect string, username and password. */
	strcpy(servername, sname);
	strcpy(username, uname);
	strcpy(authentication, auth);
	return OK;
}

int rollback_transaction(struct db_context_t *dbc)
{
	int i;

	i = SQLEndTran(SQL_HANDLE_DBC, dbc->hdbc, SQL_ROLLBACK);
	if (i != SQL_SUCCESS && i != SQL_SUCCESS_WITH_INFO) {
		LOG_ODBC_ERROR(SQL_HANDLE_STMT, dbc->hstmt);
		return ERROR;
	}
	return OK;
}
