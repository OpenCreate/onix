%.bin:%.asm
	nasm -f bin $< -o $@

master.img: boot.bin 
	yes | bximage -q -hd=16 -mode=create -sectsize=512 -imgmode=flat master.img
	dd if=boot.bin of=master.img bs=512 count=1 conv=notrunc

.PHONY: clean
clean:
	rm -rf *.bin
	rm -rf *.img

.PHONY: bochs
bochs: master.img
	bochs -q