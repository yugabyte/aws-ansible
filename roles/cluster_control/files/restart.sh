service_name=$1
base_install=$2
data_dir=$3
port_master=$4

bin_folder="$base_install/$service_name/bin/yb-$service_name"
config_file="$base_install/yb-conf/$service_name.conf"
tserver_dataDir="$data_dir/pg_data"

echo "$service_name" | egrep -iq "tserver" &>/dev/null
if [ $? -eq 0 ]; then
    ps auxwww | egrep -v grep | egrep -i "yb-$service_name.*" &>/dev/null && test -d $data_dir/yb-data/$service_name && test -d $tserver_dataDir 
    exit_code=$?
fi

echo "$service_name" | egrep -iq "master" &>/dev/null
if [ $? -eq 0 ]; then
    wget -O - -q -t 1 --timeout=60 "$(hostname):$port_master" &>/dev/null && ps auxwww | egrep -v grep | egrep -i "yb-$service_name.*" &>/dev/null && test -d $data_dir/yb-data/$service_name &>/dev/null
    exit_code=$?
fi

if [ $exit_code -ne 0 ]; 
then
    rm -rf $data_dir
    ps auxwww | egrep -v grep | egrep -i "yb-$service_name.*" | awk '{print $2}' | \
	xargs kill -9 &>/dev/null; $bin_folder --flagfile $config_file > $base_install/yb-$service_name.out 
fi

