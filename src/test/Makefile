SRC:=../

CFLAGS := -m32 # 32位程序
CFLAGS += -Qn
CFLAGS += -fno-pic
CFLAGS += -mpreferred-stack-boundary=2
CFLAGS += -fno-asynchronous-unwind-tables
CFLAGS:= $(strip ${CFLAGS})

INCLUDE:=-I$(SRC)/include

.PHONY:main.s
hello.s:main.c
	gcc $(CFLAGS) $(INCLUDE) -S $< -o $@