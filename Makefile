LDID           = $(shell command -v ldid)
STRIP          = $(shell command -v strip)

POCKTMP        = $(TMPDIR)/pockiiau
POCK_STAGE_DIR = $(POCKTMP)/stage
POCK_APP_DIR   = $(POCKTMP)/Build/Products/Release-iphoneos/pockiiau.app

.PHONY: package

package:
	# Build
	@set -o pipefail; \
		xcodebuild -jobs $(shell sysctl -n hw.ncpu) -project 'pockiiau.xcodeproj' -scheme pockiiau -configuration Release -arch arm64 -sdk iphoneos -derivedDataPath $(POCKTMP) \
		CODE_SIGNING_ALLOWED=NO DSTROOT=$(POCKTMP)/install ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO
	
	@rm -rf Payload
	@rm -rf $(POCK_STAGE_DIR)/
	@mkdir -p $(POCK_STAGE_DIR)/Payload
	@mv $(POCK_APP_DIR) $(POCK_STAGE_DIR)/Payload/pockiiau.app

	# Package
	@echo $(POCKTMP)
	@echo $(POCK_STAGE_DIR)

	@$(STRIP) $(POCK_STAGE_DIR)/Payload/pockiiau.app/pockiiau
	@$(LDID) -Sentitlements.plist $(POCK_STAGE_DIR)/Payload/pockiiau.app/
	
	@rm -rf $(POCK_STAGE_DIR)/Payload/pockiiau.app/_CodeSignature
	@ln -sf $(POCK_STAGE_DIR)/Payload Payload

	@rm -rf packages
	@mkdir -p packages

	@zip -r9 packages/pockiiau.ipa Payload
	@rm -rf Payload
	# @rm -rf $(POCKTMP)
