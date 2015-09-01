## AutosysJob Class (Package) for FNN Autosys JIL file interpretation
##
## Richard Bown
## September 2006
##
##
## Updates:
##
## 2007-12-18 - RWB - Updates for handling multiple environments and also
##                    changes included for FDW support from Project spec.
##

package AutosysJob;
use strict;

## You can set this to empty if you don't want an env prefix
##
my $env_prefix = "\$\${ENV_PREFIX}";
#my $env_prefix = "";

## Constructor
##
sub new
{
    my $self = {
        m_name => undef,                    # Job Name
        m_box => undef,                     # Box Name
        m_type => undef,                    # Job Type
        m_command => undef,                 # Command String
        m_conditions => undef,              # Job Conditions
        m_predecessorConditions => undef,   # Job Predecessor Conditions
        m_description => undef,             # Job Description
        m_id => undef,                      # ID number
        m_isBox => undef,                   # Are we a Box? 
        m_level => undef,                   # What (box) level?
        m_machine => undef,                 # What machine does the job run on?
        m_owner => undef,                   # What user does the job run as?
        m_startMins => undef,               # Minutes in the hour that the job has to start
        m_runWindow => undef,               # Time interval in which the job runs
        m_startTimes => undef,              # Any start time for this job?
        m_daysOfWeek => undef,              # Any particular days of week?
        m_watchInterval => undef,           # Watch interval
        m_watchFile => undef,               # File to wait for
        m_watchFileMinSize => undef,        # Minimum size of file to wait for
        m_termRunTime => undef,             # Time to run before terminating
        m_profile => undef,                 # Job Profile

        ## Added for FDW
        ##
        m_runCalendar => undef,             # Run Calendar
        m_externalDeps => undef,            # External Dependencies

        m_runTime => undef,                 # simulation time
        
        m_boxTerminate => undef,
        m_jobTerminate => undef
        
    };


    bless $self, 'AutosysJob';
    return $self;
}

## Name accessor
##
sub name 
{
    my ( $self, $name ) = @_;
    $self->{m_name} = $name if defined($name);
    return $self->{m_name};
}

## Box accessor
##
sub box
{
    my ( $self, $box ) = @_;
    $self->{m_box} = $box if defined($box);
    return $self->{m_box};
}

## Type accessor
##
sub type
{
    my ( $self, $type ) = @_;
    $self->{m_type} = $type if defined($type);
    return $self->{m_type};
}

## Command accessor
##
sub description
{
    my ( $self, $des ) = @_;
    $self->{m_description} = $des if defined($des);
    return $self->{m_description};
}

## Command accessor
##
sub id
{
    my ( $self, $id ) = @_;
    $self->{m_id} = $id if defined($id);
    return $self->{m_id};
}

## Command accessor
##
sub isBox
{
    my ( $self, $is ) = @_;
    $self->{m_isBox} = $is if defined($is);
    return $self->{m_isBox};
}

## Command accessor
##
sub level
{
    my ( $self, $level ) = @_;
    $self->{m_level} = $level if defined($level);
    return $self->{m_level};
}

## Command accessor
##
sub command
{
    my ( $self, $command ) = @_;
    $self->{m_command} = $command if defined($command);
    return $self->{m_command};
}

## Machine accessor
##
sub machine
{
    my ( $self, $machine ) = @_;
    $self->{m_machine} = $machine if defined($machine);
    return $self->{m_machine};
}

## Owner accessor
##
sub owner
{
    my ( $self, $owner ) = @_;
    $self->{m_owner} = $owner if defined($owner);
    return $self->{m_owner};
}

## Start Times accessor
##
sub startTimes
{
    my ( $self, $startTimes ) = @_;
    $self->{m_startTimes} = $startTimes if defined($startTimes);
    return $self->{m_startTimes};
}

## Days of Week accessor
##
sub daysOfWeek
{
    my ( $self, $daysOfWeek ) = @_;
    $self->{m_daysOfWeek} = $daysOfWeek if defined($daysOfWeek);
    return $self->{m_daysOfWeek};
}

## Start Minutes accessor
##
sub startMins
{
    my ( $self, $startMins ) = @_;
    $self->{m_startMins} = $startMins if defined($startMins);
    return $self->{m_startMins};
}

## Run Window accessor
##
sub runWindow
{
    my ( $self, $runWindow ) = @_;
    $self->{m_runWindow} = $runWindow if defined($runWindow);
    return $self->{m_runWindow};
}

## Watch Interval accessor
##
sub watchInterval
{
    my ( $self, $watchInterval ) = @_;
    $self->{m_watchInterval} = $watchInterval if defined($watchInterval);
    return $self->{m_watchInterval};
}

## Watch File accessor
##
sub watchFile
{
    my ( $self, $watchFile ) = @_;
    $self->{m_watchFile} = $watchFile if defined($watchFile);
    return $self->{m_watchFile};
}

## Watch File Min Size accessor
##
sub watchFileMinSize
{
    my ( $self, $watchFileMinSize) = @_;
    $self->{m_watchFileMinSize} = $watchFileMinSize if defined($watchFileMinSize);
    return $self->{m_watchFileMinSize};
}

## Term Run Time accessor
##
sub termRunTime
{
    my ( $self, $termRunTime) = @_;
    $self->{m_termRunTime} = $termRunTime if defined($termRunTime);
    return $self->{m_termRunTime};
}

## Profile accessor
##
sub profile 
{
    my ( $self, $profile) = @_;
    $self->{m_profile} = $profile if defined($profile);
    return $self->{m_profile};
}

## External Deps accessor
##
sub externalDeps
{
    my ( $self, $externalDeps ) = @_;
    $self->{m_externalDeps} = $externalDeps if defined($externalDeps);
    return $self->{m_externalDeps};
}

## Run Calendar accessor
##
sub runCalendar
{
    my ( $self, $runCalendar ) = @_;
    $self->{m_runCalendar} = $runCalendar if defined($runCalendar);
    return $self->{m_runCalendar};
}

sub conditions
{
    my ( $self, $conditions ) = @_;
    $self->{m_conditions} = $conditions if defined($conditions);
    return $self->{m_conditions};
}

sub predecessorConditions
{
    my ( $self, $predecessorConditions ) = @_;
    $self->{m_predecessorConditions} = $predecessorConditions if defined($predecessorConditions);
    return $self->{m_predecessorConditions};
}

sub runTime
{
    my ( $self, $runTime ) = @_;
    $self->{m_runTime} = $runTime if defined($runTime);
    return $self->{m_runTime};
}

sub boxTerminate
{
    my ( $self, $boxTerminate ) = @_;
    $self->{m_boxTerminate} = $boxTerminate if defined($boxTerminate);
    return $self->{m_boxTerminate};
}

sub jobTerminate
{
    my ( $self, $jobTerminate ) = @_;
    $self->{m_jobTerminate} = $jobTerminate if defined($jobTerminate);
    return $self->{m_jobTerminate};
}


## Format the output
##
sub print
{
    my ( $self ) = @_;
    print("\n");
    printf("Job:         %s\n", $self->{m_name}) if ($self->{m_name});
    printf("Box:         %s\n", $self->{m_box}) if ($self->{m_box});
    printf("Command:     %s\n", $self->{m_command}) if ($self->{m_command});
    printf("Condition:   %s\n", $self->{m_conditions}) if ($self->{m_conditions});
    printf("Description: %s\n", $self->{m_description}) if ($self->{m_description});
    printf("Id:          %s\n", $self->{m_id}) if ($self->{m_id});
    printf("Is Box?:     %s\n", $self->{m_isBox}) if ($self->{m_isBox});
    printf("Level:       %s\n", $self->{m_level}) if ($self->{m_level});
    print("\n");
}

1;


## Get the scalar value of the level of this job
##
sub getLevel($)
{
    my ( $self ) = @_;
    my @arr = split(/\./, $self->{m_level});
    return @arr;

}

## Autosys Format
##
## Write this job out in JIL file format using all the information we have
## populated.
##
sub autosysFormat($$$)
{
    my ( $self, $boxName, $simulate ) = @_;

    ## Get the number of levels by splitting on '.'
    ##
    my @arr = split(/\./, $self->{m_level});
    my $levels = scalar(@arr);

    ## Create an indent based on level
    ##
    my $indent = "";
    for (my $i = 0; $i < $levels; $i++)
    {
        $indent .= "  ";
    }

    print $indent."/* ----------------- ".$self->{m_name}." ----------------- */\n";
    print "\n";
    print $indent."insert_job: ".$env_prefix.$self->{m_name}."    job_type: ";

    ## Format the box type - b, f or c.   We guess 'f' type based on job name
    ##
    if ($self->{m_isBox} eq "Yes")
    {
        print "b";
    }
    else
    {
        $_ = $self->{m_name};
        if ( /^F_*/ )
        {
            print "f";
        }
        else
        {
            print "c";
        }
    }
    print "\n";



    ## Do we have a parent box to specify?
    ##
    if ($boxName ne "")
    {
        print $indent."box_name: ".$env_prefix.$boxName."\n";
    }

    ## Do we have a command line?
    ##
    if ($simulate)
    {
      print $indent."command: sleep ".$self->{m_runTime}."\n";

    } else {
    
      if ($self->{m_command} ne "")
      {
          ## replace double doublequotes by single doublequotes
          ## remove any doublequotes at the beginning and ending of the command line
          $_=$self->{m_command};
          s/""/"/g;
          s/^"//g;
          s/"$//g;

          ## Now see if we want to substitute for FDW_RUN_JOB
          ##
          if ( /%FDW_RUN_JOB%/ )
          {
            s/\%FDW_RUN_JOB\%/run_job.ksh $self->{m_name}/g;
          }

          $self->command($_);        
          print $indent."command: ".$self->{m_command}."\n";
      }
    }

    ## Machine
    ##
    if ($self->{m_machine} ne "")
    {
        print $indent."machine: ".$self->{m_machine}."\n";
    }

    ## Owner
    ##
    if ($self->{m_owner} ne "")
    {
        print $indent."owner: ".$self->{m_owner}."\n";
    }

    ## Permission (hard coded)
    ##
    print $indent."permission: gx, wx\n";

    $_ = $self->{m_name};
    s/\s*//g;
    my $jobName = $_;

    ## FDW fix for *Watcher named jobs
    ##
    if ( /-Watcher\s*$/ ) {
        print $indent."box_terminator: 1\n";
    }
    
    if ($self->{m_boxTerminate} ne "")
    {
      print $indent."box_terminator: 1\n";
    }
    
    if ($self->{m_jobTerminate} ne "")
    {
      print $indent."job_terminator: 1\n";
    }

    ## Conditions (these are internal conditions within the project file)
    ##
    my $conditionsToSet = "";
    if ($self->{m_conditions}) {
        $conditionsToSet = $self->{m_conditions};
    }

    ## External conditions - these are not derived from internal numbers
    ## but a free format field for specifying conditions.
    ##
    if (($self->{m_externalDeps}) && ($simulate == 0)) {
        if ( $conditionsToSet ne "" ) {
            $conditionsToSet .= "&";
        }

        # Add the environment prefix to the external dependency
        my $extDeps;
        $_ = $self->{m_externalDeps};
        s/([a-zA-Z])\(/$1\($env_prefix/g;
        $extDeps = $_;

        $conditionsToSet .= $extDeps;

        #print "External Deps = ".$extDeps."\n";
    }

    ## Only write this output if the condition variable has been set
    ## by internal or external dependency.
    ##
    if ($conditionsToSet ne "" ) {
        print $indent."condition: ".$conditionsToSet."\n";
    }

    ## Days of Week?
    ##
    if ($self->{m_daysOfWeek} ne "")
    {
        print $indent."date_conditions: 1\n";
        print $indent."days_of_week: ".$self->{m_daysOfWeek}."\n";
    }

    ## Run Calendar
    ##
    if ($self->{m_runCalendar} ne "")
    {
        print $indent."date_conditions: 1\n";
        print $indent."run_calendar: ".$self->{m_runCalendar}."\n";
    }

    ## Start Minutes
    ##
    if ($self->{m_startMins} ne "")
    {
        print $indent."start_mins: \"".$self->{m_startMins}."\"\n";
    }

    ## Run Window
    ##
    if ($self->{m_runWindow} ne "")
    {
        print $indent."run_window: \"".$self->{m_runWindow}."\"\n";
    }

    ## Start Times
    ##
    if ($self->{m_startTimes} ne "")
    {
        print $indent."start_times: \"".$self->{m_startTimes}."\"\n";
    }

    ## Description
    ##
    print $indent."description: \"".$self->{m_description}."\"\n";

    ## Term run Time
    ##
    if ($self->{m_termRunTime})
    {
        print $indent."term_run_time: ".$self->{m_termRunTime}."\n";
    }

    ## Alarm (hard coded)
    ##

    #print "LEVEL = ".$self->{m_level}." => ".$levels."\n";

    ## Append a profile and std files if we have a command
    ##
    if ($self->{m_command} ne "")
    {
        $_ = $jobName;

        if ( /^OV[NSR]-R/ ) {

            print $indent."alarm_if_fail: 1\n";
            print $indent."max_exit_success: 1\n";

        } else {

            if ( /^J_FNN_AST_/ || /^J_OST_SUPPORT_AST/ ) {
                print $indent."std_out_file: \$OST_LOGS/\$AUTO_JOB_NAME.log\n";
                print $indent."std_err_file: \$OST_LOGS/\$AUTO_JOB_NAME.log\n";
                print $indent."alarm_if_fail: 1\n";
            } else {
                print $indent."std_out_file: \${HOME}/autosys_logs/\${AUTO_JOB_NAME}_\${AUTORUN}.out\n";
                print $indent."std_err_file: \${HOME}/autosys_logs/\${AUTO_JOB_NAME}_\${AUTORUN}.err\n";
                print $indent."alarm_if_fail: 1\n";
            }

            ## Special cases for FDW
            ##
            if ( /^._FDW/ || /^._ORA/  ) {
                print $indent."max_exit_success: 1\n";
            }
        }

    }
    else
    {
        if ($self->{m_watchFile} ne "")
        {
            print $indent."std_out_file: \${HOME}/autosys_logs/\${AUTO_JOB_NAME}_\${AUTORUN}.out\n";
            print $indent."std_err_file: \${HOME}/autosys_logs/\${AUTO_JOB_NAME}_\${AUTORUN}.err\n";
        
            ## Watch File settings
            ##
            print $indent."watch_file: ".$self->{m_watchFile}."\n";
            print $indent."watch_file_min_size: ".$self->{m_watchFileMinSize}."\n";
            print $indent."watch_interval: ".$self->{m_watchInterval}."\n";
        }

        print $indent."alarm_if_fail: 1\n";
    }
    
    ## Set the profile
    if ($self->{m_profile} ne "")
    {
       print $indent."profile: ".$self->{m_profile}."\n";
    }
}
