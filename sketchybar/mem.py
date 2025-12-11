import psutil

def get_memory_utilization():
    # Get memory statistics
    mem = psutil.virtual_memory()
    memory_utilization = mem.percent  # Get the percentage of memory in use

    return memory_utilization

if __name__ == "__main__":
    memory_utilization = get_memory_utilization()
    print(f"{memory_utilization:.2f}%")
