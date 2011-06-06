package Chiffon::Trigger;
use strict;
use warnings;
use Exporter::Lite;
use Scalar::Util ();
use MRO::Compat;

our @EXPORT = qw/add_trigger call_trigger get_trigger_code/;

sub add_trigger {
    my ($class, %args) = @_;

    if (Scalar::Util::blessed($class)) {
        while (my ($hook, $code) = each %args) {
            push @{$class->{_trigger}->{$hook}}, $code;
        }
    } else {
        no strict 'refs';
        while (my ($hook, $code) = each %args) {
            push @{${"${class}::_trigger"}->{$hook}}, $code;
        }
    }
}

sub call_trigger {
    my ($class, $hook, @args) = @_;
    my @code = $class->get_trigger_code($hook);
    for my $code (@code) {
        $code->($class, @args);
    }
}

sub get_trigger_code {
    my ($class, $hook) = @_;
    my @code;
    if (Scalar::Util::blessed($class)) {
        push @code, @{ $class->{_trigger}->{$hook} || [] };
        $class = ref $class;
    }
    no strict 'refs';
    for (reverse @{mro::get_linear_isa($class)}) {
        push @code, @{${"${_}::_trigger"}->{$hook} || []};
    }
    return @code;
}

1;
__END__

=head1 NAME

Chiffon::Trigger - Trigger system for Chiffon

=head1 SYNOPSIS

    package MyClass;
    use Chiffon::Trigger;

    __PACKAGE__->add_trigger('Foo');
    __PACKAGE__->call_trigger('Foo');

=head1 DESCRIPTION

This is a trigger system for Chiffon. You can use this class for your class using trigger system.

This module forked from Amon2::Trigger

=head1 METHODS

=over 4

=item __PACKAGE__->add_trigger($name:Str, \&code:CodeRef)

=item $obj->add_trigger($name:Str, \&code:CodeRef)

You can register the callback function for the class or object.

When you register callback code on object, the callback is only registered to object, not for class.

I<Return Value>: Not defined.

=item __PACKAGE__->call_trigger($name:Str);

=item $obj->call_trigger($name:Str);

This method calls all callback code for $name.

I<Return Value>: Not defined.

=item __PACKAGE__->get_trigger_code($name:Str)

=item $obj->get_trigger_code($name:Str)

You can get all of trigger code from the class and ancestors.

=back

=head1 FAQ

=over 4

=item WHY DON'T YOU USE L<Class::Trigger>?

L<Class::Trigger> does not support get_trigger_code.

=back
