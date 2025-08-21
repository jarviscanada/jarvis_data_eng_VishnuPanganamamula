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

# VM stats and VM hostname are saved as variables (vmstat_mb results will be in MB)
vmstat_mb=$(vmstat --unit M)
hostname=$(hostname -f)

# Retrieving hardware specifics for host users
memory_free=$(echo "$vmstat_mb" | awk '{print $4}' | tail -1 | xargs)
cpu_idle=$(echo "$vmstat_mb" | awk '{print $15}' | tail -1 | xargs)
cpu_kernel=$(echo "$vmstat_mb" | awk '{print $14}' | tail -1 | xargs)
disk_io=$(vmstat -d | awk '{print $10}' | tail -1 | xargs)
disk_available=$(df -BM | grep -E "^/dev/sda2" | awk '{print $4}' | sed 's/M//')

# Current timestamp in UTC format
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

echo "Available Memory (MB): $memory_free
CPU Idle Time (%): $cpu_idle
CPU Kernel Time (%): $cpu_kernel
Disk Space (# of read/write operations): $disk_io
Available Disk Space (MB): $disk_available
Timestamp: $timestamp"

# SQL Sub-query to find matching host ID in host_info table
host_id="(SELECT id FROM host_info WHERE hostname='$hostname')";

# Creating insert statement --> inserts server usage data into host_usage table
insert_statement="INSERT INTO host_usage (timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available)
VALUES ('$timestamp', $host_id, $memory_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_available);"

# Setting up environment variable for password
export PGPASSWORD=$psql_password

# psql command
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_statement"

exit $?

