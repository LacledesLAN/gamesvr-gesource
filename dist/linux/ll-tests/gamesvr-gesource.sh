#!/bin/bash -i

#####################################################################################################
### CONFIG VARS #####################################################################################
declare LLTEST_CMD="/app/srcds_run -debug -game gesource +map ge_archives -insecure -norestart +sv_lan 1";
declare LLTEST_NAME="gamesvr-gesource-$(date '+%H%M%S')";
#####################################################################################################
#####################################################################################################

# Runtime vars
declare LLCOUNTER=0;
declare LLBOOT_ERRORS="";
declare LLTEST_HASFAILURES=false;
declare LLTEST_LOGFILE="$LLTEST_NAME"".log";
declare LLTEST_RESULTSFILE="$LLTEST_NAME"".results";

# Server log file should contain $1 because $2
function should_have() {
    if ! grep -i -q "$1" "$LLTEST_LOGFILE"; then
        echo $"[FAIL] - '$2'" >> "$LLTEST_RESULTSFILE";
        LLTEST_HASFAILURES=true;
    else
        echo $"[PASS] - '$2'" >> "$LLTEST_RESULTSFILE";
    fi;
}

# Server log file should NOT contain $1 because $2
function should_lack() {
    if grep -i -q "$1" "$LLTEST_LOGFILE"; then
        echo $"[FAIL] - '$2'" >> "$LLTEST_RESULTSFILE";
        LLTEST_HASFAILURES=true;
    else
        echo $"[PASS] - '$2'" >> "$LLTEST_RESULTSFILE";
    fi;
}

# Command $1 should make server return $2
function should_echo() {
    tmux has-session -t "$LLTEST_NAME" 2>/dev/null;
    if [ "$?" == 0 ] ; then
        LLCOUNTER=0;
        LLTMP=$(md5sum "$LLTEST_LOGFILE");
        tmux send -t "$LLTEST_NAME" C-z "$1" Enter;

        while true; do
            sleep 0.5;

            if  (( "$LLCOUNTER" > 30)); then
                echo $"[FAIL] - Command '$!' TIMED OUT";
                LLTEST_HASFAILURES=true;
                break;
            fi;

            if [[ $(md5sum "$LLTEST_LOGFILE") != "$LLTMP" ]]; then
                should_have "$2" "'$1' should result in '$2' (loop iterations: $LLCOUNTER)";
                break;
            fi;

            (( LLCOUNTER++ ));
        done;
    else
        echo $"[ERROR]- Could not run command '$1'; tmux session not found" >> "$LLTEST_RESULTSFILE";
        LLTEST_HASFAILURES=true;
    fi;
}

function print_log() {
    if [ ! -s "$LLTEST_LOGFILE" ]; then
        echo $'\nOUTPUT LOG IS EMPTY!\n';
        exit 1;
    else
        echo $'\n[LOGFILE OUTPUT]';
        awk '{print "»»  " $0}' "$LLTEST_LOGFILE";
    fi;
}

# Check prereqs
command -v awk > /dev/null 2>&1 || echo "awk is missing";
command -v md5sum > /dev/null 2>&1 || echo "md5sum is missing";
command -v sleep > /dev/null 2>&1 || echo "sleep is missing";
command -v tmux > /dev/null 2>&1 || echo "tmux is missing";

# Check that MALLOC_CHECK_ is set properly
# MALLOC_CHECK_=0 is required for gesource to run
if [ "$MALLOC_CHECK_" != "0" ]; then
    echo "MALLOC_CHECK_ is not set or is not to 0. Verify environment variables."
    exit 2
fi

# Prep log file
: > "$LLTEST_LOGFILE"
if [ ! -f "$LLTEST_LOGFILE" ]; then
    echo 'Failed to create logfile: '"$LLTEST_LOGFILE"'. Verify file system permissions.';
    exit 2;
fi;

# Prep results file
: > "$LLTEST_RESULTSFILE"
if [ ! -f "$LLTEST_RESULTSFILE" ]; then
    echo 'Failed to create logfile: '"$LLTEST_RESULTSFILE"'. Verify file system permissions.';
    exit 2;
fi;

echo $'\n\nRUNNING TEST: '"$LLTEST_NAME";
echo $'Command: '"$LLTEST_CMD";
echo "Running under $(id)"$'\n';

# Execute test command in tmux session
tmux new -d -s "$LLTEST_NAME" "sleep 0.5; $LLTEST_CMD";
sleep 0.3;
tmux pipe-pane -t "$LLTEST_NAME" -o "cat > $LLTEST_LOGFILE";

while true; do
    tmux has-session -t "$LLTEST_NAME" 2>/dev/null;
    if [ "$?" != 0 ] ; then
        echo $'terminated.\n';
        LLBOOT_ERRORS="Test process self-terminated";
        break;
    fi;

    if  (( "$LLCOUNTER" >= 29 )); then
        if [ -s "$LLTEST_LOGFILE" ] && ((( $(date +%s) - $(stat -L --format %Y "$LLTEST_LOGFILE") ) > 20 )); then
            echo $'succeeded.\n';
            break;
        fi;

        if (( "$LLCOUNTER" > 120 )); then
            echo $'timed out.\n';
            LLBOOT_ERRORS="Test timed out";
            break;
        fi;
    fi;

    if (( LLCOUNTER % 5 == 0 )); then
        echo -n "$LLCOUNTER...";
    fi;

    (( LLCOUNTER++ ));
    sleep 1;
done;

if [ ! -s "$LLTEST_LOGFILE" ]; then
    echo $'\nOUTPUT LOG IS EMPTY!\n';
    exit 1;
fi;

if [ ! -z "${LLBOOT_ERRORS// }" ]; then
    echo "Boot error: $LLBOOT_ERRORS";
    print_log;
    exit 1;
fi;

#####################################################################################################
### TESTS ###########################################################################################
# Stock Golden-Eye Source server tests (Source SDK 2007)
should_lack 'free(): invalid pointer' 'Environmental variable MALLOC_CHECK_ needs to set to 0 for the server to run';
should_lack 'Server restart in 10 seconds' 'Server is not boot-looping';
should_lack 'Running the dedicated server as root' 'Server is not running under root';
should_have 'Game.dll loaded for "GoldenEye: Source"' 'srcds_run loaded GoldenEye Source';
should_lack 'map load failed:' 'Server was able to load a map';
should_lack 'Failed to load $include VMT file (materials/GOLDENEYE/' 'No failures to include VMT assets';
should_lack "Invalid scenario '' included in gameplay cycle file. Ignored." 'No EOL issues in mapcycles';

# Verify server responds to commands
should_echo "say STARTING COMMAND TESTS" 'Console: STARTING COMMAND TESTS';
#####################################################################################################
#####################################################################################################

tmux has-session -t "$LLTEST_NAME" 2>/dev/null;
if [ "$?" == 0 ] ; then
    tmux kill-session -t "$LLTEST_NAME";
fi;

print_log;

echo $'\n[TEST RESULTS]\n';
cat "$LLTEST_RESULTSFILE";

echo $'\n[OUTCOME]\n';
if [ $LLTEST_HASFAILURES = true ]; then
    echo $'Checks have failures!\n\n';
    exit 1;
fi;

echo $'All checks passed!\n\n';
exit 0;
