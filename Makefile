LINUX := linux
BUSYBOX := busybox

ARCH := arm64
CROSS_COMPILE :=aarch64-linux-gnu-

default: kernel.img rootfs.img

run: kernel.img rootfs.img
	qemu-system-aarch64 -machine type=virt -cpu cortex-a57 -m 2048m -kernel kernel.img -nographic -append "root=/dev/ram rdinit=/sbin/init" -initrd rootfs.img -net nic,model=e1000 -net user

debug: kernel.img rootfs.img
#	qemu-system-x86_64 -kernel kernel.img -append "root=/dev/ram rdinit=/sbin/init kgdboc=ttyS0,115200 kgdbwait" -initrd rootfs.img -net nic,model=e1000 -net user -serial tcp::1234,server &
#	TMPFILE=$$(mktemp) && echo "target remote localhost:1234" > $$TMPFILE && gdb -x $$TMPFILE $(LINUX)/vmlinux

clean:
	rm -f kernel.img rootfs.img

update: $(LINUX)/.config $(BUSYBOX)/.config
	yes "" | make ARCH=$(ARCH) -C $(LINUX) oldconfig
	yes "" | make ARCH=$(ARCH) -C $(BUSYBOX) oldconfig

kernel.img: $(LINUX)/.config
	make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -C $(LINUX) -j4
	cp $(LINUX)/arch/arm64/boot/Image $@

rootfs.img: $(BUSYBOX)/.config
	make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -C $(BUSYBOX) install -j4
	./mkrootfs $@

install $(LINUX)/.config $(BUSYBOX)/.config:
	./install

.PHONY: default run debug clean update install
