package Argo;
use strict;
use ArgoMatch;

my $yearBase = 70;   # Base year for epoch conversion
my $debug = 0;       # debug status

## Constructor
##
sub new {
  my $self = {
    database_server  => "",
    database_connect_string => "",
    database_user => "",
    database_pass => "",
    database_file_storage => "",
    process_limit    => 0,
    history_timeout  => 600,
    history_size     => 100,
    max_connections  => 50,
    port_base        => 30767
  };


  bless $self, 'Argo';
  return $self;
}

sub createSession() {
}

sub dropSession() {
}

sub writeSearch() {
}

sub getResults() {
}

# logMsg - static member for writing out to centralised log file
#
sub logMsg($) {
  my ( $message ) = @_;
  chomp($message);
  print now()." - ".$message."\n";
}

sub loadConfig() {

  my ( $self, $configFile ) = @_;
  open RO, $configFile or die "Could not open \"".$configFile."\"";
  while ( <RO> ) {

    # skip comments and empty lines
    #
    next if ( /^\s*#/ || /^\s*$/ );

    # trim EOLs
    #
    chop();

    my @values = split(/=/);

    if ( $values[0] eq "DB_SERVER" ) {
      $self->{database_server} = $values[1];
    } elsif ( $values[0] eq "DB_CONN_STRING" ) {
      $self->{database_connect_string} = $values[1];
    } elsif ( $values[0] eq "DB_USER" ) {
      $self->{database_user} = $values[1];
    } elsif ( $values[0] eq "DB_PASSWORD" ) {
      $self->{database_pass} = $values[1];
    } elsif ( $values[0] eq "DB_FILE_STORAGE" ) {
      $self->{database_file_storage} = $values[1];
    } elsif ( $values[0] eq "PROCESS_LIMIT" ) {
      $self->{process_limit} = $values[1];
    } elsif ( $values[0] eq "CONNECTIONS" ) {
      $self->{max_connections} = $values[1];
    } elsif ( $values[0] eq "HISTORY_TIMEOUT" ) {
      $self->{history_timeout} = $values[1];
    } elsif ( $values[0] eq "HISTORY_SIZE" ) {
      $self->{history_size} = $values[1];
    } elsif ( $values[0] eq "PORT_BASE" ) {
      $self->{port_base} = $values[1];
    } else {
      die "unsupported config entry for \"".$values[0]."\"";
    }
  }

  close(RO);

  my $showConfig = 0;
  if ( $showConfig ) {
    print "  Config:\n";
    print "  DB_SERVER=".$self->{database_server}."\n";
    print "  PROCESS_LIMIT=".$self->{process_limit}."\n";
    print "  CONNECTIONS=".$self->{max_connections}."\n";
    print "  HISTORY_TIMEOUT=".$self->{history_timeout}."\n";
    print "  HISTORY_SIZE=".$self->{history_size}."\n";
    print "  PORT_BASE=".$self->{port_base}."\n";
  }
}

sub dbServer {
    my ( $self, $database_server ) = @_;
    $self->{database_server} = $database_server if defined($database_server);
    return $self->{database_server};
}

sub dbConnection {
    my ( $self, $database_connect_string ) = @_;
    $self->{database_connect_string} = $database_connect_string if defined($database_connect_string);
    return $self->{database_connect_string};
}

sub dbUser {
    my ( $self, $database_user ) = @_;
    $self->{database_user} = $database_user if defined($database_user);
    return $self->{database_user};
}

sub dbPass {
    my ( $self, $database_pass ) = @_;
    $self->{database_pass} = $database_pass if defined($database_pass);
    return $self->{database_pass};
}

sub dbFileStorage {
    my ( $self, $database_file_storage ) = @_;
    $self->{database_file_storage} = $database_file_storage if defined($database_file_storage);
    return $self->{database_file_storage};
}

sub processLimit {
    my ( $self, $process_limit ) = @_;
    $self->{process_limit} = $process_limit if defined($process_limit);
    return $self->{process_limit};
}

sub maxConnections {
    my ( $self, $max_connections ) = @_;
    $self->{max_connections} = $max_connections if defined($max_connections);
    return $self->{max_connections};
}

sub historyTimeout {
    my ( $self, $history_timeout ) = @_;
    $self->{history_timeout} = $history_timeout if defined($history_timeout);
    return $self->{history_timeout};
}

sub historySize {
    my ( $self, $history_size ) = @_;
    $self->{history_size} = $history_size if defined($history_size);
    return $self->{history_size};
}

sub portBase {
    my ( $self, $port_base ) = @_;
    $self->{port_base} = $port_base if defined($port_base);
    return $self->{port_base};
}

# Format the time to now
#
sub now() {
  my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
  my @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
  my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
  my $year = 1900 + $yearOffset;

  # other format which we're ignoring
  #my $theTime = "$hour:$minute:$second, $weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
  #return $theTime; 

  return sprintf("%02d/%02d/%04d %02d:%02d:%02d", $dayOfMonth, $month + 1, $year, $hour, $minute, $second);
}

sub epochTime() {
  my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
  my @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
  my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
  my $year = 1900 + $yearOffset;

  my $epoch = 86400 * ( 365 * ($yearOffset - $yearBase) + $dayOfYear) + ( $hour * 3600 ) + ( $minute * 60) + $second;
  return $epoch;

  #return sprintf("%04d%02d%02d%02d%02d%02d", $year, $month + 1, $dayOfMonth, $hour, $minute, $second);
}

# Convert our epoch time to real time
#
sub epochToReal($) {
  my $time = $_[0];
  my @months = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
  my ($sec, $min, $hour, $day,$month,$year) = (localtime($time))[0,1,2,3,4,5,6];

  # You can use 'gmtime' for GMT/UTC dates instead of 'localtime'
  # $months[$month]

  return sprintf("%02d/%02d/%04d %02d:%02d:%02d", $day, $month + 1, $year + 1900, $hour, $min, $sec);
}

# Get a set of records from a flat file
#
sub getRecordSet($$$$$) {
  my ($self, $startTime, $endTime, $id, $text) = @_;

  # We will load the file into a hash and sort it according to time
  #
  my %rows = ();
  my @row;
  my $file = $self->dbFileStorage();

  open RO, "<", $file or die "Could not open database file \"".$file."\" for reading.";

  while (<RO>) {

    # Strip off the line feeds
    #
    chomp();

    # Split on colon
    #
    @row = split(/:/);

    # if we have three records
    if ($#row eq 2) {

      # If the time field is corect and the id field is not the calling id
      # then insert it into the hash as we've got a time match.
      #
      if ( $row[0] >= $startTime && $row[0] < $endTime && $row[1] ne $id) {
        #print $row[0].":".$row[1].":".$row[2];

        # Get a percentage match score on the text
        #
        my $score = getTextScore($row[2], $text);

        # if above a threshold then insert into hash
        if ($score > 0.1) {

          print "INSERTING MATCH\n";
          my $argoMatch = new ArgoMatch($text, $row[2], $id, $row[1], $score, now(), $row[0]);
          #$rows{$score} = $argoMatch;
          $rows{$row[0]} = $argoMatch;
          #$rows{$row[0]} = $row[1].":".$row[2];

        }
      }
    }
  }

  # Close the file
  #
  close RO;

  return %rows;
}

sub getTextScore($$) {
  my ( $text1, $text2 ) = @_;
  my $score = 0;

  my %map1 = getWordMap($text1);
  my %map2 = getWordMap($text2);
  my $word1 = "";

  my $numerator = 0;
  my $divisor = keys(%map1);
  if (keys(%map2) > $divisor) {
    $divisor = keys(%map2);
  }

  if ($debug ne 0) {
    print "\nDIVISOR = $divisor\n"; 
    print "MAP1 = ".keys(%map1)."\n";
    print "MAP2 = ".keys(%map2)."\n";
  }

  foreach ( keys %map1  )  {

    $word1 = $_;

    #print "TEXT1 = ".$_."\n";

    foreach ( keys %map2 ) {
      $numerator++ if ( $word1 eq $_ );
      #print "TEXT2 = ".$_."\n";
    }
  }

  $score = $numerator / $divisor;
  print "SCORE = $score\n";

  return $score;
}


# Compress our word list into a lower case map of all words
#
sub getWordMap {
    my ( $text ) = @_;
    return map { lc $_ => 1 }
        map { /([a-z0-9\-']+)/i }
        split /\s+/s, $text;
}

1;
