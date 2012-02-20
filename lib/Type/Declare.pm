package Type::Declare;

use strict;
use warnings;

use parent 'Exporter';

use Type::Constraint::Simple;
use Type::Helpers qw( install_t_sub );
use Type::Registry qw( internal_types_for_package register );

our @EXPORT = qw( declare anon parent where message inline_with );

sub import {
    my $package = shift;

    my $caller = caller();

    $package->export_to_level( 1, $package, @_ );

    install_t_sub(
        $caller,
        internal_types_for_package($caller)
    );

    return;
}

sub declare {
    my $name = shift;
    my %p    = (
        name => $name,
        map { @{$_} } @_,
    );

    my $tc = Type::Constraint::Simple->new(
        %p,
        declared_at => _declared_at(),
    );

    register( scalar caller(), $name, $tc, 'exportable' );

    return;
}

sub anon {
    my %p = map { @{$_} } @_;

    return Type::Constraint::Simple->new(
        %p,
        declared_at => _declared_at(),
    );
}

sub _declared_at {
    my ( $package, $filename, $line, $sub ) = caller(2);

    return {
        package  => $package,
        filename => $filename,
        line     => $line,
        sub      => $sub,
    };
}

sub parent ($) {
    return [ parent => $_[0] ];
}

sub where (&) {
    return [ constraint => $_[0] ];
}

sub message (&) {
    return [ message_generator => $_[0] ];
}

sub inline_with (&) {
    return [ inline_generator => $_[0] ];
}

1;
