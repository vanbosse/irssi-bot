# == WHAT
# All around bot.
#
# == WHO
# Jeroen Van den Bossche, 2012
#
# == INSTALL
# Save it in ~/.irssi/scripts/ and do /script load bot.pl
# OR
# Save it in ~/.irssi/scripts/autorun and (re)start Irssi

use strict;
use Irssi;
use LWP::Simple;
use HTML::TokeParser;
use vars qw($VERSION %IRSSI);

$VERSION = '0.1';
%IRSSI = (
	authors => 'Jeroen Van den Bossche',
	name => 'bot',
	description => 'All around Irssi bot.',
	license => 'GPL',
	url => 'http://vanbosse.be',
);

sub process_message {
	my ($server, $msg, $target) = @_;
	my $command = 0;

	return unless $target =~ /^#(lolfut|catenadev)/;
	if ($msg =~ m/^!bot\s(.+?)$/)
	{
		$command = $1;
	}
	return unless $command;
	return if $msg eq $command;

	my $output = "Computer says no, try \"!bot help\".";
	if ($command eq "help")
	{
		$output = "Commands: ibood";
	}
	elsif ($command eq "ibood")
	{
		my $url = "http://ibood.com/be/nl/";
		my $html = get($url);
		my $parser = HTML::TokeParser->new(\$html);
		my ($title, $price) = 0;
		while ( my $token = $parser->get_tag("a") )
		{
			if ($token->[1]{id} eq "link_product")
			{
				$title = $parser->get_trimmed_text;
				last;
			}
		}
		$parser = HTML::TokeParser->new(\$html);
		while ( my $token = $parser->get_tag("span") )
		{
			if ($token->[1]{class} eq "price")
			{
				$parser->get_tag("span");
				$price = $parser->get_text;
				last;
			}
		}
		$output = "iBood: $title. (\x{20AC}$price)";
	}

	$server->command("msg $target $output");
}

Irssi::signal_add_last('message public', sub {
	my ($server, $msg, $nick, $mask, $target) = @_;
	Irssi::signal_continue($server, $msg, $nick, $mask, $target);
	process_message($server, $msg, $target);
});
Irssi::signal_add_last('message own_public', sub {
	my ($server, $msg, $target) = @_;
	Irssi::signal_continue($server, $msg, $target);
	process_message($server, $msg, $target);
});
