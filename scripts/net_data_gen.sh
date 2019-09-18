#!/bin/bash
echo "THIS SCRIPT GENERATE TESTDATA IN POSTGRESQL DB WHILE X SECONDS"

display_help() {
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -h, --hostname       Destination Hostname/IP/Socketfile"
    echo "   -p, --port           Destination Port"
    echo "   -d, --database       Destination Database"
    echo "   -u, --username       Destination DB Username"
    echo "   -w. --password       Password for DB User"
    echo "   -s, --seconds        Executiontime in seconds"
    echo "   -?, --help           Show Help, this one"
    echo

    exit 1
}


while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--host)
    dest_host="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--port)
    dest_port="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--database)
    dest_database="$2"
    shift
    shift
    ;;
    -u|--username)
    dest_user="$2"
    shift # past argument
    shift # past value
    ;;
    -w|--password)
    dest_pwd="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--seconds)
    exec_time="$2"
    shift # past argument
    shift # past value
    ;;
    -?|--help)
    display_help
    shift
    ;;
    *)
    false_param=1
    shift
    ;;
esac
done

if [[ ${false_param} == 1 ]]
then
	echo "UNKNOWN PARAM FOUND, TRY AGAIN :)"
  	display_help
fi

dest_host=${dest_host:=${PGHOST}}
dest_port=${dest_port:=${PGPORT}}
dest_database=${dest_database:=${PGDATABASE}}
dest_user=${dest_user:=${USER}}
dest_pwd=${dest_pwd:=${PGPASSWORD}}
exec_time=${exec_time:=30}

echo "Destination:"
echo "HOST => ${dest_host}"
echo "PORT => ${dest_port}"
echo "USER => ${dest_user}"
echo "PWD  => ${dest_pwd}"
echo "EXEC TIME => ${exec_time}" 


gen_table() {
	export PGPASSWORD=${dest_pwd}
	psql -h ${dest_host} -p ${dest_port} -U ${dest_user} -d ${dest_database} -c "CREATE TABLE IF NOT EXISTS gendata (val text, check_date timestamp without time zone DEFAULT now())" 
}

gen_data() {
	end=$((SECONDS+${exec_time}))
	
	while [ $SECONDS -lt $end ]; do
		random_string=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
		psql -h ${dest_host} -p ${dest_port} -U ${dest_user} -d ${dest_database} -c "INSERT INTO gendata(val) VALUES ('${random_string}')"
	done
}

read -r -p "Are you sure? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        gen_table
	gen_data
        ;;
    *)
        echo "Bye"
        ;;
esac
