STATIC_TARGET = $(addsuffix $(STATIC_LIB_SUFFIX), $(addprefix $(BUILD_OUTPUT_STATIC_LIBS), $(LOCAL_MODULE)))
STATIC_TARGET_LIB = $(LOCAL_SRC_FILES)
INCLUDE_PATH = $(addprefix $(PREBUILT_INCLUDES), $(LOCAL_MODULE))

all: $(STATIC_TARGET)
$(STATIC_TARGET):$(STATIC_TARGET_LIB)
	#mkdir -p $(INCLUDE_PATH)
	#cp -r $(LOCAL_EXPORT_C_INCLUDES)/* $(INCLUDE_PATH)/
	cp $(<) $(@)
	@echo $(@) done