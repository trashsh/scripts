#!/bin/bash
source /etc/profile
source ~/.bashrc

cat << EOF | mysql mydatabase
CREATE TABLE info (id bigint NOT NULL, $1 varchar(128), $2 varchar(128));
EOF