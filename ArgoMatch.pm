package ArgoMatch;
use strict;

## Constructor
##
sub new($$$$$$$) {
  my $self = {
    search_text    => $_[1],
    match_text     => $_[2],
    search_id      => $_[3],
    match_id       => $_[4],
    compatibility  => $_[5],
    search_time    => $_[6],
    original_time  => $_[7]
  };

  bless $self, 'ArgoMatch';
  return $self;
}

sub print {
  my ( $self ) = @_;
  print "SEARCH TEXT   : $self->{search_text}\n";
  print "MATCH TEXT    : $self->{match_text}\n";
  print "SEARCH ID     : $self->{search_id}\n";
  print "MATCH ID      : $self->{match_id}\n";
  print "COMPATIBILITY : $self->{compatibility}\n";
  print "SEARCH TIME   : $self->{search_time}\n";
  print "ORIGINAL TIME : ".Argo::epochToReal($self->{original_time})."\n";
  print "\n";
}

1;
