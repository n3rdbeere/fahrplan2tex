#!/usr/bin/perl

use strict;
use warnings;

use JSON::Parse 'json_file_to_perl';
#use HTML::Formatter;

use Data::Printer;
use Data::Dumper;

my $json = json_file_to_perl('schedule.json');

my @event_list;

#foreach my $day ( @{ $json->{schedule}->{conference}->{days}->[0] } ) {
#foreach my $day ( $json->{schedule}->{conference}->{days}->[0]  ) {
my @days = @{ $json->{schedule}->{conference}->{days} };
foreach my $day (@days) {
    print "one day has passed\n";
    foreach my $event ( @{ $day->{rooms}->{"Project 2501"} }, @{ $day->{rooms}->{"Simulacron-3"} } )
    {
        print "push event\n";
        push @event_list, $event;
    }
}

sub parse_day {
  my $date = shift;
  $date =~ m/^....-..-(..)T/;
  my $day = $1-12;
  return $day;
}

sub make_persons {
  my (@persons_array) = @_;
  my @persons = @{ $persons_array[0] };
  my $speaker_list = "";
#  return join ', ', map { $_->{full_public_name} } @persons;
  foreach my $person (@persons) {
    $speaker_list = $speaker_list.", ".$person->{full_public_name}; 
  }
  $speaker_list =~ s/^\,\s+//;
  #p $speaker_list;
  return $speaker_list;
}

sub print_tex {
  my $event  = shift();

  open my $fh, '> :encoding(UTF-8)', "talk" or die $!;

  # oder wenn die reihenfolge egal ist, einfach ( keys %$event )
  foreach my $key (qw(dayofevent shorttext longtext duration language speaker location timeofevent track eventtitle subtitle id)) {
    printf $fh '\%s{%s}', $key, $event->{$key};
    print $fh "\n";
  }

  close $fh;
}

sub regex_magic{
  my $string = shift;
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
  $string =~ s/\%/\\\%/g;
  $string =~ s/\&/\\\&/g;
  return $string;
}

sub clean_special_chars {
  my $string = shift;
  $string =~ s/\&/\\\&/g;
  $string =~ s/\$/\\\$/g;
  $string =~ s/\_//g;
  $string =~ s/\%/\\\%/g;
  $string =~ s/\^\w*//g;
  return $string;
}

#sub clean_html {
#  return $string = HTML::FormatMarkdown->format_string(shift());
#}

sub make_latex {
  #my (@event_list) = @_;
  my %event_props;
  foreach my $event (@event_list) {
    #print_tex#(
     my $shorttext = regex_magic($event->{abstract});
     my $longtext = regex_magic($event->{description});
     #my $duration = $event->{duration};
     #$duration =~ s/\://g;
     #my $track = $event->{track};
     #$track =~ s/\&/\\\&/g;
     #);
     my $language;
     if ($event->{language} =~ /^*$/) { $language = "nA"; } else { $language = $event->{language}; }
     %event_props = 
      (
      #{
        dayofevent            => clean_special_chars(parse_day( $event->{date} )),
        #shorttext            => %$event->{abstract},
        #shorttext            => $event->{abstract},
        shorttext             => $shorttext,
        #longtext             => $event->{description},
        longtext              => $longtext,
        duration              => clean_special_chars($event->{duration}),
        language              => clean_special_chars($language),
        speaker               => clean_special_chars(make_persons( $event->{persons} ) ),
        location              => clean_special_chars($event->{room}),
        timeofevent           => clean_special_chars($event->{start}),
        track                 => clean_special_chars($event->{track}),
        eventtitle            => clean_special_chars($event->{title}),
        subtitle              => clean_special_chars($event->{subtitle}),
        id                    => $event->{id}
      );
      #}
      #print "Event Properties:\n";
      #p %event_props;
    #);
#    push %event_props, 
    print_tex(\%event_props);
    system("pdflatex", "-jobname", $event->{id}, "main.tex");
    system("rm", $event->{id}.".aux");
    system("rm", $event->{id}.".log");
  }
    # pdflatex -jobname <name>
}
#print "make_latex:\n";
make_latex();
#p @event_list;
