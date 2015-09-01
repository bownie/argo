#!/usr/bin/perl -w
##
## Generate an output file from a CSV.
##

## We always use strict and -w - these options ensure that our
## internal variables are always used correctly in scope and 
## saves us a lot of pain later on in the development.
##
## An absolutely vital tip for supportable perl!
##
use strict;
use Getopt::Std;
use AJob;


## Get the AJob package to store our Job data
##
use AJob;

my $outputMode="txt";

## You can set this to empty if you don't want an env prefix
##
my $env_prefix = "\$\${ENV_PREFIX}";
#my $env_prefix = "";

## This definition is sometimes required when using packages.
#our @ISA = qw(AJob);

## Global variable definitions
##
## (Note that as we are using 'strict' we have to use 'my' 
##  to define all of these variables - the same as in any function)
##
##
my @jobList;
my @topLevelBox = ();
my %jobHash = ();
my $jobCount = 1;
my $projectFile = "";
my $simulate = 0;

## Define global debug flag
##
my $debug = 0;

## Usage function
##
sub usage()
{
   print "\n  Usage:\n\n";
   print "    ".$0." [-s] <MS Project export file>\n\n";
   print "            -s : simulation mode\n\n";
}

## Perl options
##
sub processOptions()
{
  ## Options hash
  ##
  my %options = ();

  ## Get our options - only help flags in this case
  ##
  getopts("hHs",\%options);

  if (defined($options{h}) || defined($options{H}))
  {
    usage();
    exit(0);
  }

  if (defined($options{s}))
  {
    $simulate = 1;
  }

  ## Set the project file to the single remaining argument
  ##
  $projectFile = $ARGV[0];

  ## Is the $projectFile variable non-empty?
  ##
  if (!defined($projectFile) || $projectFile eq "")
  {
    usage();
    exit(1);
  }

  ## Does the project file path exist and is the file readable?
  ##
  if (! -r $projectFile)
  {
    print "Cannot find input file \"".$projectFile."\"\n";
    exit(1);
  }
}


## Read a JIL file and process it into our internal storage format.
## This basically involves parsing the input file - a line at a time
## and transfering the contents of each line straight into a set of
## perl variables.   These variables are then used to populate an
## instance of the AJob class - and this instance is pushed onto
## the global hash %jobHash.
##
##
sub processProject($)
{
    
    ## Filename
    ##
    my ($file) = @_;
    my ($job, $jobNumber, $jobDesc, $jobName, @jobDepends, $jobDependsString, $jobConditions, @jobPredConds, $jobPredCondString, $jobPredConditions, $jobIsBox, $jobHierarchy, $jobScript);
    my ($jobNotes, $jobMachine, $jobOwner, $jobStartMins, $jobDaysOfWeek, $jobStartTimes, $jobWatchInterval, $jobWatchFile, $jobWatchFileMinSize, $jobProfile, $jobTermRunTime, $jobRunWindow, $jobRunCalendar, $jobExternalDeps, $jobRunTime);
    my ($jobBoxTerminate, $jobJobTerminate);
    
    open(FILE, $file) or die ("Cannot open file $file");
    while(<FILE>)
    {
        #chomp;

        ## Remove ^M character from end of line.
        s/
//g;

        ## Find boxes or jobs (or file watchers) in the formatted output
        ## file and create an AutosysJob object from the results.
        ##
        ##  We use a split(\t) on the input now rather than the big regexp
        ##
        my @shuckInput = split(/\t/);
        my $shuckSize = @shuckInput;
        
        ## Reset these on each pass through
        ##
        $jobNotes = "";
        $jobMachine = "";
        $jobOwner = "";
        $jobStartMins = "";
        $jobDaysOfWeek = "";
        $jobStartTimes = "";
        $jobWatchInterval = "";
        $jobWatchFile = "";
        $jobWatchFileMinSize = "";
        $jobProfile = "";
        $jobTermRunTime = "";
        $jobRunWindow = "";
        $jobRunCalendar = "";
        $jobExternalDeps = "";
        $jobRunTime = "0";
        $jobBoxTerminate = "";
        $jobJobTerminate = "";

        ## Debug block
        ##
        if ($debug ne 0) {
            my $row;
            my $i = 0;
            foreach $row (@shuckInput) {
                print $i++." ROW = ".$row."\n";
            }

            print "\n\n";
        }

        ## Split these and clear up the output and then set the relevant
        ## 
        if ($shuckSize > 0)
        {
            $_ = $shuckInput[0];
            s/^\s*([0-9]+)\s*$/$1/g;
            $jobNumber = $_;           # [0-9]+

            if ($shuckSize > 1) {
                $_ = $shuckInput[1];
                s/^\s*(.+)\s*$/$1/g;
                $jobDesc = $_;
            }

            if ($shuckSize > 2) {
                $_ = $shuckInput[2];
                s/^\s*([\.a-zA-Z0-9_-]+)\s*$/$1/g;
                $jobName = $_;
            }

            if ($shuckSize > 3 ) {
                $_ = $shuckInput[3];
                s/^\s*(.*)\s*$/$1/g;
                $jobDependsString = $_;
            }

            if ($shuckSize > 4) {
                $_ = $shuckInput[4];
                s/^\s*([a-z;: "]*)\s*$/$1/g;
                $jobPredCondString = $_;
            }

            if ($shuckSize > 5) {
                $_ = $shuckInput[5];
                s/^\s*([A-Za-z ]*)\s*$/$1/g;
                $jobIsBox = $_;
            }

            if ($shuckSize > 6) {
                $_ = $shuckInput[6];
                s/^\s*([0-9.]*)\s*$/$1/g;
                $jobHierarchy = $_;
            }

            if ($shuckSize > 7) {
                $_ = $shuckInput[7];
                s/^\s*(.*)\s*$/$1/g;
                $jobNotes = $_;
            }

            if ($shuckSize > 8) {
                $_ = $shuckInput[8];
                s/^\s*(.*)\s*$/$1/g;
                $jobScript = $_;
            }

            if ($shuckSize > 9) {
                $_ = $shuckInput[9];
                s/^\s*(.*)\s*$/$1/g;
                $jobMachine = $_;
            }

            if ($shuckSize > 10) {
                $_ = $shuckInput[10];
                s/^\s*(.*)\s*$/$1/g;
                $jobOwner = $_;
            }

            if ($shuckSize > 11) {
                $_ = $shuckInput[11];
                s/^\s*(.*)\s*$/$1/g;
                $jobStartMins = $_;
            }

            if ($shuckSize > 12) {
                $_ = $shuckInput[12];
                s/^\s*(.*)\s*$/$1/g;
                $jobDaysOfWeek = $_;
            }

            if ($shuckSize > 13) {
                $_ = $shuckInput[13];
                s/^\s*(.*)\s*$/$1/g;
                $jobStartTimes = $_;
            }

            if ($shuckSize > 14) {
                $_ = $shuckInput[14];
                s/^\s*(.*)\s*$/$1/g;
                $jobWatchInterval = $_;
            }

            if ($shuckSize > 15) {
                $_ = $shuckInput[15];
                s/^\s*(.*)\s*$/$1/g;
                $jobWatchFile = $_;
            }

            if ($shuckSize > 16) {
                $_ = $shuckInput[16];
                s/^\s*(.*)\s*$/$1/g;
                $jobWatchFileMinSize = $_;
            }

            if ($shuckSize > 17) {
                $_ = $shuckInput[17];
                s/^\s*(.*)\s*$/$1/g;
                $jobTermRunTime = $_;
            }

            if ($shuckSize > 18) {
                $_ = $shuckInput[18];
                s/^\s*(.*)\s*$/$1/g;
                $jobProfile = $_;
            }

            ## jobRunWindow
            ##
            if ($shuckSize > 19) {
                $_ = $shuckInput[19];
                s/^\s*(.*)\s*/$1/g;
                $jobRunWindow = $_;
            }

            ## Run Calendar
            ##
            if ($shuckSize > 20) {
                $_ = $shuckInput[20];
                s/^\s*(.*)\s*/$1/g;
                $jobRunCalendar = $_;
            }

            ## External Deps
            ##
            if ($shuckSize > 21) {
                $_ = $shuckInput[21];
                s/^\s*(.*)\s*/$1/g;
                $jobExternalDeps = $_;
            }

            if ($shuckSize > 22) {
                $_ = $shuckInput[22];
                s/^\s*(.*)\s*/$1/g;
                $jobRunTime = $_;
            }
            
            if ($shuckSize > 23) {
                $_ = $shuckInput[23];
                s/^\s*(.*)\s*/$1/g;
                $jobBoxTerminate = $_;
            }
            
            if ($shuckSize > 24) {
                $_ = $shuckInput[24];
                s/^\s*(.*)\s*/$1/g;
                $jobJobTerminate = $_;
            }

            if ($debug eq 1)
            {
                print "JOB NUM     = ".$jobNumber."\n";
                print "JOB DESC    = ".$jobDesc."\n";
                print "JOB NAME    = ".$jobName."\n";
                print "JOB DEPENDS = ".$jobDependsString."\n";
                print "JOB IS BOX  = ".$jobIsBox."\n";
                print "JOB LEVEL   = ".$jobHierarchy."\n";
                print "JOB SCRIPT  = ".$jobScript."\n";
                print "\n";
            }

            ## Clean up the dependency string - remove double quotes
            ##
            if ( $jobDependsString =~ m/;/ )
            {
                $_ = $jobDependsString;
                s/"//g;
                $jobDependsString = $_;
            }

            $jobNotes =~ s/"//g;

            ## Split dependency string on semi-colons
            ##
            $jobConditions = "";
            @jobDepends = split(/;/, $jobDependsString);
            for (@jobDepends)
            {
                $jobConditions .= $_." ";
            }

            print $jobConditions."\n\n" if ($debug);

            ## Clean up the predecessor conditions string - remove double quotes
            ##
            if ( $jobPredCondString =~ m/;/ )
            {
                $_ = $jobPredCondString;
                s/"//g;
                $jobPredCondString = $_;
            }

            ## Split predecessor conditions string on semi-colons
            ##
            $jobPredConditions = "";
            @jobPredConds = split(/;/, $jobPredCondString);
            for (@jobPredConds)
            {
                $jobPredConditions .= $_." ";
            }

            print $jobPredConditions."\n\n" if ($debug);
            

            $job = new AutosysJob();
            $job->name($jobName);
            $job->conditions($jobConditions);
            $job->predecessorConditions($jobPredConditions);
            $job->description($jobNotes);
            $job->id($jobNumber);
            $job->isBox($jobIsBox);
            $job->level($jobHierarchy);
            $job->command($jobScript);
            $job->machine($jobMachine);
            $job->owner($jobOwner);
            $job->startMins($jobStartMins);
            $job->daysOfWeek($jobDaysOfWeek);
            $job->runWindow($jobRunWindow);
            $job->startTimes($jobStartTimes);
            $job->watchInterval($jobWatchInterval);
            $job->watchFile($jobWatchFile);
            $job->watchFileMinSize($jobWatchFileMinSize);
            $job->termRunTime($jobTermRunTime);
            $job->profile($jobProfile);
            $job->runCalendar($jobRunCalendar);
            $job->externalDeps($jobExternalDeps);
            $job->runTime($jobRunTime);
            $job->boxTerminate($jobBoxTerminate);
            $job->jobTerminate($jobJobTerminate);

            ## Push the job onto the hash
            ##
            $jobHash{$jobNumber} = $job;

            print $job->print()."\n" if ($debug);

            ## loop around to next line
            next; 
        }
    }

    close(FILE);
}


## Format a JIL file output from the information we've got stored in
## the jobHash.    We do some cleverness here to work out whether we're
## in a box and what the parent box should be if we are.
##
##
sub formatJIL()
{
    my ($job, $jobId);
    my $boxName = "";
    my $lastBoxLevel = 0;
    my %boxLevels = ();

    foreach $jobId (sort { $jobHash{$a}->id() <=> $jobHash{$b}->id() } keys %jobHash)
    {
       ## Recover the Job pointer from the hash
       ##
       $job = $jobHash{$jobId};

       ## If the current level is below the top level then apply a boxname
       ## otherwise there should be no box specified.
       ##
       if ($job->getLevel() gt 1)
       {
           $boxName = $boxLevels{$job->getLevel() - 1};
       }
       else
       {
           $boxName = "";
       }

       ## Format the job using the AutosysJob class method
       ##
       $job->autosysFormat($boxName, $simulate);

       ## Store a box name if we have one
       ##
       if ($job->isBox() eq "Yes")
       {
           $boxLevels{$job->getLevel()} = $job->name();
       }

       print "\n\n";
    }
}

## Cycle through all jobs and convert conditions to real job names
## ready for Autosys.   This is taking the Microsoft Project formatted
## dependencies that are based on numbers separated by semi-colons and
## replacing them with Autosys conditions.
##
## i.e.
##
##      45;128
##
##  becomes:
##
##      s(J_FNN_MY_JOB) & s(J_FNN_MY_OTHER_JOB)
##
##
sub fixConditions()
{
    my ($job, $jobId);
    my $converted = "";

    foreach $jobId (sort { $jobHash{$a}->id() <=> $jobHash{$b}->id() } keys %jobHash)
    {
        $job = $jobHash{$jobId};
        $converted = "";
        my @arr = split(/ /, $job->conditions());

        my $arraySize = @arr;

        for (my $i = 0; $i < $arraySize; $i++)
        {
            my $condChar="s";

            if ($job->predecessorConditions() ne "")
            {
                my @predCondArr = split(/ /, $job->predecessorConditions());
                  $condChar=$predCondArr[$i];
            }
            
            $converted .= $condChar."(".$env_prefix.$jobHash{$arr[$i]}->name().")";
        

            ## Append an ampersand
            ##
            if ($i < ( $arraySize - 1) )
            {
                $converted .= "&";
            }    

            #print "ARR ".$arr[$i]." ";
        }

        $job->conditions($converted);
    }
}


## Process the command line options
##
processOptions();

## Parse the source file and generate the object hash
##
processProject($projectFile);

## Now fix all the conditions so that they point to Autosys job names
## rather than the reference numbers.
##
fixConditions();

## Directly output the JIL file based on the information - send the
## output to stdout.
##
formatJIL();

## Exit with success
##
exit(0);
