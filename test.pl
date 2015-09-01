#!/usr/bin/perl -w
use strict;

use Argo;

#Argo::loadConfig("argo.conf");
#print "Argo::history_timeout = ".Argo::$history_timeout."\n"; 

my $argo = new Argo();

$argo->loadConfig("argo.conf");
Argo::logMsg("hello there this is my message");
