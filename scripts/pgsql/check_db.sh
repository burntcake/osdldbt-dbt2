#!/bin/sh

# check_db.sh
#
# This file is released under the terms of the Artistic License.  Please see
# the file LICENSE, included in this package, for details.
#
# Copyright (C) 2002 Mark Wong & Open Source Development Lab, Inc.
#
# 01 May 2003

DIR=`dirname $0`
. ${DIR}/init_env.sh || exit

# Load tables
echo customer
$PSQL -d $DB_NAME -c "select count(*) from customer"
echo district
$PSQL -d $DB_NAME -c "select count(*) from district"
echo history 
$PSQL -d $DB_NAME -c "select count(*) from history"
echo item    
$PSQL -d $DB_NAME -c "select count(*) from item"
echo new_order
$PSQL -d $DB_NAME -c "select count(*) from new_order"
echo order_line
$PSQL -d $DB_NAME -c "select count(*) from order_line"
echo orders  
$PSQL -d $DB_NAME -c "select count(*) from orders"
echo stock   
$PSQL -d $DB_NAME -c "select count(*) from stock"
echo warehouse
$PSQL -d $DB_NAME -c "select count(*) from warehouse"
