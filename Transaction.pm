package Maypole::Plugin::Transaction;

use strict;

our $VERSION = '0.02';

Maypole::Config->mk_accessors('transaction_exception');

=head1 NAME

Maypole::Plugin::Transaction - Transaction handling for Maypole

=head1 SYNOPSIS

Simple transaction:

    package MyApp;

    use Maypole::Application qw(Transaction);

    # You should AutoCommit by default
    MyApp->setup( 'dbi:Pg:dbname=myapp', 'myuser', 'mypass',
        { AutoCommit => 1 } );

    sub do_something : Exported {
        my ( $self, $r ) = @_;
        my $h = CGI::Untaint->new( %{ $r->{params} } );
        warn 'Transaction failed!'
            unless $r->transaction( sub { $self->create_from_cgi($h) } );
    }

Advanced transaction with exception handling:

    package MyApp;

    use Maypole::Application qw(Transaction);
    use Maypole::Constants;
    use Exception::Class TransactionException =>
      { description => 'Transaction failed, so rolled back' };

    # You should AutoCommit by default
    MyApp->setup( 'dbi:Pg:dbname=myapp', 'myuser', 'mypass',
        { AutoCommit => 1 } );
    MyApp->config->transaction_exception('TransactionException');

    sub exception {
        my ( $r, $e ) = @_;
        if ( $e->isa('TransactionException') ) {
            warn "Transaction failed: $e";
            # Do something to correct the failure
            return OK;
        }
        return ERROR;
    }

    sub do_something : Exported {
        my ( $self, $r ) = @_;
        my $h = CGI::Untaint->new( %{ $r->{params} } );
        $r->transaction( sub { $self->create_from_cgi($h) } );
    }

=head1 DESCRIPTION

Commit, Rollback and throwing Exceptions!

Note that you need Maypole 2.0 or newer to use this module!

=head2 transaction

    my $status = $r->transaction( $coderef, $exception );

Returns true or false, the exception argument is optional.

=cut

sub transaction {
    my ( $r, $code, $ex ) = @_;
    local $r->config->classes->[0]->db_Main->{AutoCommit};
    eval { &$code };
    if ( my $err = $@ ) {
        eval { $r->dbi_rollback };
        $ex ||= $r->config->transaction_exception;
        $ex->throw( error => $err ) if $ex;
    }
    return $@ ? 0 : 1;
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
