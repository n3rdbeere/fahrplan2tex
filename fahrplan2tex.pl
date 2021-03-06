# this script extracts data of the Fahrplan and calls with these
# the herald moderator card - template in LaTeX 
# for the Chaos Communication Camp 2015
# Author: Simon Putzke / nerdbeere <nerdbeere@c-base.org>
# this file is licensed under the Beer-Ware License:

##############################
#   #### Beer-Ware License (Revision 42): ####
# nerdbeere wrote this file. As long as you retain this notice
# you can do whatever you want with this stuff.
# If we meet some day, and you think this stuff is worth it,
# you can buy me a beer in return.
# <nerdbeere@c-base.org>
##############################

#!/usr/bin/perl

use strict;
use warnings;

use JSON::Parse 'json_file_to_perl';

my $json = json_file_to_perl('schedule.json');

my $fahrplan_url = "https://events.ccc.de/camp/2015/Fahrplan/schedule.json";

my @event_list;
my $fahrplan_version = $json->{schedule}->{version};
$fahrplan_version =~ m/^(\d+)\.(\d+)/;
my $version = "cards_version_" . $1 . "_" . $2; 

my @days = @{ $json->{schedule}->{conference}->{days} };
foreach my $day (@days) {
    foreach my $event ( @{ $day->{rooms}->{"Project 2501"} }, @{ $day->{rooms}->{"Simulacron-3"} } ) {
        push @event_list, $event;
    }
}

sub download_json_file {
  system ("wget", "-O", "schedule.json", $fahrplan_url);
  return;
}

sub parse_day {
  my ($date) = @_;
  $date =~ m/^....-..-(..)T/;
  my $day = $1-12;
  return $day;
}

sub make_persons {
  my (@persons_array) = @_;
  my @persons = @{ $persons_array[0] };
  my @speaker_list;
  foreach my $person (@persons) {
    push @speaker_list, $person->{full_public_name};
  }
  return (join ", ", @speaker_list);
}

sub print_tex {
  my ($event)  = @_;

  open my $fh, '> :encoding(UTF-8)', "talk" or die $!;

  foreach my $key ( keys %{ $event } ) {
    printf $fh '\%s{%s}', $key, $event->{$key};
    print $fh "\n";
  }
  close $fh;
}

sub clean_special_chars{
  my ($string) = @_;
  $string =~ s/\<ol\>\w*\<li\>//;
  $string =~ s/\<\/p\>/\\\\/g;
  $string =~ s/\<li\>/\\\\\- /g;
  $string =~ s/<[^>]*>//g;
  $string =~ s/\s\s+/ /g;
  $string =~ s/\\\\ \\\\/\\\\\\\\/g;
  $string =~ s/\s?\\\\\s?/\\\\/g;
  $string =~ s/\\\\$//;
  $string =~ s/\_//g;
  $string =~ s/\^\w*//g;
  $string =~ s/\&/\\\&/g;
  $string =~ s/\$/\\\$/g;
  $string =~ s/\%/\\\%/g;
  $string =~ s/\#/\\\#/g;
  return $string;
}

#sub clean_special_chars {
#  my $string = shift;
#  $string =~ s/\&/\\\&/g;
#  $string =~ s/\$/\\\$/g;
#  $string =~ s/\_//g;
#  $string =~ s/\#/\\\#/g;
#  $string =~ s/\^\w*//g;
#  return $string;
#}

sub make_latex {
  my %event_props;
  foreach my $event (@event_list) {
     my $shorttext = $event->{abstract};
     my $longtext = $event->{description};
     my $translation;
     my $technical;
     if ($event->{room} eq "Project 2501") { 
      $translation  = "8011";
      $technical    = "1611";
     }
     elsif ($event->{room} eq "Simulacron-3") { 
      $translation  = "8012";
      $technical    = "1621";
     }
     %event_props = 
      (
        dayofevent            => clean_special_chars(parse_day( $event->{date} )),
        shorttext             => clean_special_chars($shorttext),
        longtext              => clean_special_chars($longtext),
        duration              => clean_special_chars($event->{duration}),
        language              => clean_special_chars($event->{language}),
        speaker               => clean_special_chars(make_persons( $event->{persons} ) ),
        location              => clean_special_chars($event->{room}),
        timeofevent           => clean_special_chars($event->{start}),
        track                 => clean_special_chars($event->{track}),
        eventtitle            => clean_special_chars($event->{title}),
        subtitle              => clean_special_chars($event->{subtitle}),
        id                    => $event->{id},
        translation           => $translation,
        technical             =>  $technical
      );
    print_tex(\%event_props);
    system("pdflatex", "-jobname", $version."/".$event->{room}."_".$event->{date}, "main.tex");
    #system("pdflatex", "-jobname", $event->{room}."_".$event->{date}, "main.tex");
    system("rm", $version."/".$event->{room}."_".$event->{date}.".aux", $version."/".$event->{room}."_".$event->{date}.".log");
  }
}

system("mkdir", "-p", $version);
print "new file downloaded" if download_json_file;
make_latex();
