# Variables
SDK_DIR = ${PLAYDATE_SDK_PATH}
SDK_BIN = $(SDK_DIR)/bin
SIM = $(SDK_BIN)/PlaydateSimulator

SRC_DIR = source
BIN_DIR = build

CC = pdc

GAME   = $(notdir $(CURDIR))
TARGET = $(BIN_DIR)/$(GAME).pdx


# Auxiliary Build
.PHONY: build
.PHONY: rebuild
.PHONY: clean
.PHONY: run

build: compile

rebuild: clean build

clean:
	@rm -rf $(TARGET)

run: rebuild
	@$(SIM) $(TARGET)

# Compile Source File

compile: $(SRC_DIR)/main.lua
	$(CC) --skip-unknown $(SRC_DIR) $(TARGET)


# Update Game Info in pdxinfo file
.PHONY: updateInfo

INFO_FILE = $(SRC_DIR)/pdxinfo

updateInfo:
	@echo "Update $(INFO_FILE).."
#	@$(shell gawk -i inplace 'BEGIN {FS=OFS="="} $$1=="name" {$$2="$(GAME)"} 1' $(INFO_FILE))
	@$(shell gawk -i inplace 'BEGIN {FS=OFS="="} $$1=="buildNumber" {$$2=$$2+1} 1' $(INFO_FILE))