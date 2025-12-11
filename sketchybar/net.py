import psutil
import time

def get_net_bandwidth(interval=1):
    # Get initial network stats
    net_start = psutil.net_io_counters()
    bytes_sent_start = net_start.bytes_sent
    bytes_recv_start = net_start.bytes_recv

    # Wait for the specified interval
    time.sleep(interval)

    # Get updated network stats
    net_end = psutil.net_io_counters()
    bytes_sent_end = net_end.bytes_sent
    bytes_recv_end = net_end.bytes_recv

    # Calculate send and receive rates (in bytes per second)
    send_rate = (bytes_sent_end - bytes_sent_start) / interval
    recv_rate = (bytes_recv_end - bytes_recv_start) / interval

    return send_rate, recv_rate

if __name__ == "__main__":
    send_rate, recv_rate = get_net_bandwidth()
    print(f"[{send_rate/1024**2:.2f}, {recv_rate/1024**2:.2f}] MB/s")
