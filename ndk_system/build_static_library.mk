COMMAND = $(eval $(call test-cmd1))

WORK_DIR=$(addprefix $(BUILD_OUTPUT_STATIC_LIBS), $(LOCAL_MODULE))
STATIC_TARGET = $(addsuffix $(STATIC_LIB_SUFFIX), $(addprefix $(BUILD_OUTPUT_STATIC_LIBS), $(LOCAL_MODULE)))
STATIC_TARGET_C_OBJ = $(patsubst %.c, %.o, $(filter %.c, $(LOCAL_SRC_FILES)))
STATIC_TARGET_CPP_OBJ = $(patsubst %$(LOCAL_CPP_EXTENSION), %.o, $(filter %$(LOCAL_CPP_EXTENSION), $(LOCAL_SRC_FILES)))
STATIC_TARGET_STATIC_LIBRARIES = $(addprefix $(BUILD_OUTPUT_STATIC_LIBS), $(addsuffix $(STATIC_LIB_SUFFIX), $(LOCAL_STATIC_LIBRARIES)))

$(STATIC_TARGET_C_OBJ): STATIC_TARGET_CFLAG = $(LOCAL_CFLAGS) -std=c99  -g -rdynamic -ldl -funwind-tables
$(STATIC_TARGET_CPP_OBJ): STATIC_TARGET_CPPFLAG = $(LOCAL_CPPFLAGS)
$(STATIC_TARGET_C_OBJ) $(STATIC_TARGET_CPP_OBJ): STATIC_TARGET_FLAG += $(addprefix -I, $(LOCAL_C_INCLUDES))
$(STATIC_TARGET_C_OBJ) $(STATIC_TARGET_CPP_OBJ): STATIC_TARGET_FLAG += $(addprefix -I, $(ROOT_DIR)/include)
$(STATIC_TARGET_C_OBJ) $(STATIC_TARGET_CPP_OBJ): STATIC_TARGET_FLAG += -L$(BUILD_OUTPUT_STATIC_LIBS)

all: $(STATIC_TARGET)
$(STATIC_TARGET):$(STATIC_TARGET_C_OBJ) $(STATIC_TARGET_CPP_OBJ)
	@$(TARGET_AR) rcs $@ $^
	$(call quiet-cmd-echo-build, AR, $@)
$(STATIC_TARGET_C_OBJ):%.o:%.c
	@$(TARGET_GCC) $(STATIC_TARGET_CFLAG) $(STATIC_TARGET_FLAG) -c -fpic $< -o $@
	$(call quiet-cmd-echo-build, GCC, $@)
$(STATIC_TARGET_CPP_OBJ):%.o:%$(LOCAL_CPP_EXTENSION)
	@$(TARGET_GPP) $(STATIC_TARGET_CPPFLAG) $(STATIC_TARGET_FLAG) -c -fpic $< -o $@
	$(call quiet-cmd-echo-build, G++, $@)

#$(eval $(call make-target-static-library, "test"))
#$(call addsuffix, STATIC_LIB_SUFFIX, $(LOCAL_MODULE))
#$(addsuffix , STATIC_LIB_SUFFIX, $(LOCAL_MODULE))
#LOCAL_CFLAGS += $(addprefix -I , $(LOCAL_C_INCLUDES))

define quiet-cmd-echo-build
	@echo "  [$1]  $2"
endef

define build-static-library
	@echo "enter build-static-library"$1
	@echo $(LOCAL_CFLAGS)

	@-mkdir $(WORK_DIR)
	@for i in $(LOCAL_STATIC_LIBRARIES); \
	do \
		cd $(WORK_DIR); \
		$(TARGET_AR) x $(BUILD_OUTPUT_STATIC_LIBS)/$$i$(STATIC_LIB_SUFFIX); \
	done
	@$(TARGET_AR) rcs $@ $^ `ls $(WORK_DIR)/*.o`
	@rm -fr $(WORK_DIR)


$(eval $(call make-target-static-library,\
	$(addsuffix , STATIC_LIB_SUFFIX, $(LOCAL_MODULE)),\
	$(patsubst %.c, %.o, $(LOCAL_SRC_FILES)),\
	$(LOCAL_CFLAGS)))
endef

define make-target-static-library
$1:$2
	ar r $1 $2
$2:%.o:%.c
	gcc $3 -c $$< -o $$@
endef

define test-cmd
target:test
	@echo "++++++++++++++++++++++++++++++++++test running..."
endef

define test-cmd1
	"----------------------------------test running..."
endef
