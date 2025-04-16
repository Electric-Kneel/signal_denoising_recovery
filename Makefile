
TARGET = signal_processing
SRC = src/main.cu
CC = nvcc

all:
	$(CC) $(SRC) -o $(TARGET)

clean:
	rm -f $(TARGET)
