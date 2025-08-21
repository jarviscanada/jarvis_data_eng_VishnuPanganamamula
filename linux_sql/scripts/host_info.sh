# Setting up arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Check number of arguments in the command (If less than 5, then invalid command)
if [ "$#" -ne 5 ]; then
  echo "Illegal number of parameters"
  exit 1
fi

# VM hostname and lscpu_out are saved as variables
hostname=$(hostname -f)
lscpu_out=`lscpu`

# Retrieving hardware specifics information
cpu_number=$(echo "$lscpu_out" | grep -E '^CPU\(s\):' | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | grep -E '^Architecture:' | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | grep -E '^Model name:' | awk -F: '{print $2}' | xargs)
cpu_mhz=$(grep "cpu MHz" /proc/cpuinfo | head -n1 | awk '{print $4}' | xargs)
l2_cache=$(echo "$lscpu_out" | grep -E '^L2 cache:' | awk '{print $3}' | xargs)
total_mem=$(vmstat --unit M | tail -1 | awk '{print $4}')

# Current timestamp in UTC format
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

echo "Hostname: $hostname"
echo "CPU Number: $cpu_number
Architecture: $cpu_architecture
CPU Model: $cpu_model
CPU Clock Speed (MHz): $cpu_mhz
L2 Cache (KB): $l2_cache
Total Memory (KB): $total_mem
Timestamp: $timestamp"

# Creating insert statement --> inserts host info data
insert_stmt="INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, timestamp, total_mem)
VALUES ('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, '$timestamp', $total_mem);"

# Setting up environment variable for password
export PGPASSWORD=$psql_password

# psql command
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

exit $?

