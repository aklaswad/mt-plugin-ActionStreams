# Action Streams (C) 2009-2010 Six Apart, Ltd. All Rights Reserved.
# This library is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

package ActionStreams::Init;

use strict;

use MT::Author;

sub init_app { 1 }

## REMOVE ME ASAP
sub hide_ts {
    my ( $cb, $app ) = @_;
    my $mode = $app->mode;
    my $type = $app->param('_type');
    if ( MT->VERSION >= 5
        && ( $mode eq 'list_theme'
          || ( $mode eq 'view' && $type eq 'blog' ))) {
        my $component = MT->component('actionstreams');
        my $registry = $component->registry;
        delete $registry->{template_sets}{streams};
    }
    1;
}

MT::Author->install_meta({
    columns => [
        'other_profiles',
    ],
});

sub MT::Author::other_profiles {
    my $user = shift;
    my( $type ) = @_;
    my $profiles = $user->meta( 'other_profiles' );
    require Storable;
    $profiles = Storable::thaw($profiles) if !ref $profiles;
    $profiles ||= [];
    return $type ?
        [ grep { $_->{type} eq $type } @$profiles ] :
        $profiles;
}

sub MT::Author::add_profile {
    my $user = shift;
    my( $profile ) = @_;
    my $profiles = $user->other_profiles;
    push @$profiles, $profile;
    $user->meta( other_profiles => $profiles );
    $user->save;
}

sub MT::Author::remove_profile {
    my $user = shift;
    my( $type, $ident ) = @_;
    my $profiles = [ grep {
        $_->{type} ne $type || $_->{ident} ne $ident
    } @{ $user->other_profiles } ];
    $user->meta( other_profiles => $profiles );
    $user->save;
}

1;
