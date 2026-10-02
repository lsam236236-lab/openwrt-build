#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
# 修改 Newifi D2 DTS 16M → 64M
cat > target/linux/ramips/dts/mt7621_d-team_newifi-d2.dts <<EOF
/dts-v1/;

#include <dt-bindings/gpio/gpio.h>
#include <dt-bindings/input/input.h>

/ {
	compatible = "d-team,newifi-d2", "mediatek,mt7621";
	model = "D-Team Newifi D2";

	aliases {
		led-boot = &led_status;
		led-failsafe = &led_status;
		led-running = &led_status;
		led-upgrade = &led_status;
	};

	chosen {
		bootargs = "console=ttyS0,57600";
	};

	leds {
		compatible = "gpio-leds";

		led_status: status {
			label = "newifi-d2:blue:status";
			gpios = <&gpio0 18 GPIO_ACTIVE_LOW>;
		};
	};

	keys {
		compatible = "gpio-keys";

		reset {
			label = "reset";
			gpios = <&gpio0 13 GPIO_ACTIVE_LOW>;
			linux,code = <KEY_RESTART>;
		};
	};
};

&spi0 {
	status = "okay";

	flash@0 {
		compatible = "jedec,spi-nor";
		reg = <0x0 0x4000000>;
		spi-max-frequency = <50000000>;

		partitions {
			compatible = "fixed-partitions";
			#address-cells = <1>;
			#size-cells = <1>;

			partition@0 {
				label = "u-boot";
				reg = <0x0 0x30000>;
				read-only;
			};

			partition@30000 {
				label = "u-boot-env";
				reg = <0x30000 0x10000>;
				read-only;
			};

			factory: partition@40000 {
				label = "factory";
				reg = <0x40000 0x10000>;
				read-only;
			};

			partition@50000 {
				label = "firmware";
				reg = <0x50000 0x3fb0000>;
			};
		};
	};
};

&ethernet {
	mtd-mac-address = <&factory 0x2e>;
};

&pcie {
	status = "okay";
};

&pcie0 {
	wifi@0,0 {
		compatible = "mediatek,mt76";
		reg = <0x0000 0 0 0 0>;
		mediatek,mtd-eeprom = <&factory 0x0>;
	};
};

&pcie1 {
	wifi@0,0 {
		compatible = "mediatek,mt76";
		reg = <0x0000 0 0 0 0>;
		mediatek,mtd-eeprom = <&factory 0x8000>;
	};
};

&gpio0 {
	status = "okay";
};
EOF

# 修改mt7621.mk，把IMAGE_SIZE改成64m
sed -i '/d-team_newifi-d2/,/endef/s/IMAGE_SIZE := 16m/IMAGE_SIZE := 64m/' target/linux/ramips/image/mt7621.mk
