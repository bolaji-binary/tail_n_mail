#!perl

## Spell check as much as we can

use 5.006;
use strict;
use warnings;
use Test::More;
use utf8;
use open qw/ :std :utf8/;
select(($|=1,select(STDERR),$|=1)[1]);

my (@testfiles, $fh);

if (! $ENV{RELEASE_TESTING}) {
	plan (skip_all =>  'Test skipped unless environment variable RELEASE_TESTING is set');
}
elsif (!eval { require Text::SpellChecker; 1 }) {
	plan skip_all => 'Could not find Text::SpellChecker';
}
else {
	opendir my $dir, 't' or die qq{Could not open directory 't': $!\n};
	@testfiles = map { "t/$_" } grep { /^\w.+\.(t|pl)$/ } readdir $dir;
	closedir $dir or die qq{Could not closedir "$dir": $!\n};
	plan tests => 2+@testfiles;
}

my %okword;
my $file = 'Common';
while (<DATA>) {
	if (/^## (.+):/) {
		$file = $1;
		next;
	}
	next if /^#/ or ! /\w/;
	for (split) {
		$okword{$file}{$_}++;
	}
}


sub spellcheck {
	my ($desc, $text, $filename) = @_;
	my $check = Text::SpellChecker->new(text => $text);
	my %badword;
	while (my $word = $check->next_word) {
		next if $okword{Common}{$word} or $okword{$filename}{$word};
		$badword{$word}++;
	}
	my $count = keys %badword;
	if (! $count) {
		pass ("Spell check passed for $desc");
		return;
	}
	fail ("Spell check failed for $desc. Bad words: $count");
	for (sort keys %badword) {
		diag "$_\n";
	}
	return;
}


## First, plain text files
for my $file (qw/Changes/) {
	if (!open $fh, '<', $file) {
		fail (qq{Could not find the file "$file"!});
	}
	else {
		{ local $/; $_ = <$fh>; }
		close $fh or warn qq{Could not close "$file": $!\n};
		if ($file eq 'Changes') {
			s{\S+\@\S+\.\S+}{}gs;
		}
		spellcheck ($file => $_, $file);
	}
}

## Now the comments
SKIP: {
	if (!eval { require File::Comments; 1 }) {
		skip ('Need File::Comments to test the spelling inside comments', 11+@testfiles);
	}

	my $fc = File::Comments->new();

	my @files;
	for (sort @testfiles) {
		push @files, "$_";
	}


	for my $file (@testfiles, 'tail_n_mail') {
		if (! -e $file) {
			fail (qq{Could not find the file "$file"!});
		}
		my $string = $fc->comments($file);
		if (! $string) {
			fail (qq{Could not get comments from file $file});
			next;
		}
		$string = join "\n" => @$string;
		$string =~ s/=head1.+//sm;
		spellcheck ("comments from $file" => $string, $file);
	}


}


__DATA__
## These words are okay

## Common:

Deckelmann
MAXSIZE
Mullane
bucardo
config
env
hideflatten
perl
txt
whitespace

## Changes:

arg
args
Arsen
autovac
autovacuum
chunked
config
CSV
devbox
durations
ENV
filename
FILEx
Fiske
func
Github
GSM
havepid
havetimestamp
html
http
Johan
LASTFILE
logrotate
lookahead
mailsig
MAILSUBJECT
mailzero
Markus
metacharacters
Nagios
nolastfile
nonparsed
pgbouncer
pgformat
pglog
pgpidre
PID
POSIX
Postgres
pre
regex
regexes
Sabino
Seiler
serios
skipfilebyregex
SQL
sqlstate
SQLSTATE
Stasic
syslog
syslogs
sysread
tempfile
timestamp
timestamps
Tolley
uniques
unlink
Urbański
whitespace
Zimmermann

## tail_n_mail:

GetOptions
bucardo
chesnok
clusterwide
config
cperl
cron
filename
filenames
globals
greg
hostname
http
https
lastfile
maxsize
pgbouncer
pid
rc
regex
regexes
Sabino
selena
smtp
tempfile
timestamp
turnstep
usr
wiki
wrapline

