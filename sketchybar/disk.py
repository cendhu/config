import psutil
import time

def get_disk_rw_rate(interval=1):
    # Get initial disk IO counters
    io_start = psutil.disk_io_counters()
    read_start = io_start.read_bytes
    write_start = io_start.write_bytes

    # Wait for the specified interval
    time.sleep(interval)

    # Get updated disk IO counters
    io_end = psutil.disk_io_counters()
    read_end = io_end.read_bytes
    write_end = io_end.write_bytes

    # Calculate read and write rates (in bytes per second)
    read_rate = (read_end - read_start) / interval
    write_rate = (write_end - write_start) / interval

    return read_rate, write_rate

if __name__ == "__main__":
    read_rate, write_rate = get_disk_rw_rate()
    print(f"[{read_rate/1024**2:.2f}, {write_rate/1024**2:.2f}] MB/s")
