# WARNING:
# This is a generated file and should not be edited directly.
# look into generate-tests.pl instead
use v6;
use Test;
plan *;

# This class, designed to help simplify the tests, is very much in a transitional
# state.  But it works as well as the previous version at the moment.  I'm checking
# it in just to clean up my local build (and save a remote copy as I take my
# the machine it lives on vacation).  Should have more updates to this over the 
# next several days.  --colomon, Sept 3rd 2009.

class AngleAndResult
{
    has $.angle_in_degrees;
    has $.result;

    our @radians-to-whatever = (1, 180 / pi, 200 / pi, 1 / (2 * pi));
    our @degrees-to-whatever = ((312689/99532) / 180, 1, 200 / 180, 1 / 360);
    our @degrees-to-whatever-num = @degrees-to-whatever.map({ .Num });

    multi method new(Int $angle_in_degrees is copy, $result is copy) {
        self.bless(*, :$angle_in_degrees, :$result);
    }
    
    method complex($imaginary_part_in_radians, $base) {
        my $z_in_radians = $.angle_in_degrees / 180.0 * pi + ($imaginary_part_in_radians)i;
		$z_in_radians * @radians-to-whatever[$base];
    }
    
    method num($base) {
		$.angle_in_degrees * @degrees-to-whatever-num[$base];
    }
    
    method rat($base) {
		$.angle_in_degrees * @degrees-to-whatever[$base];
    }
    
    method int($base) {
        $.angle_in_degrees;
    }
}

my @sines = ( 
    AngleAndResult.new(-360, 0),
    AngleAndResult.new(135 - 360, 1/2*sqrt(2)),
    AngleAndResult.new(330 - 360, -0.5),
    AngleAndResult.new(0, 0),
    AngleAndResult.new(30, 0.5),
    AngleAndResult.new(45, 1/2*sqrt(2)),
    AngleAndResult.new(90, 1),
    AngleAndResult.new(135, 1/2*sqrt(2)),
    AngleAndResult.new(180, 0),
    AngleAndResult.new(225, -1/2*sqrt(2)),
    AngleAndResult.new(270, -1),
    AngleAndResult.new(315, -1/2*sqrt(2)),
    AngleAndResult.new(360, 0),
    AngleAndResult.new(30 + 360, 0.5),
    AngleAndResult.new(225 + 360, -1/2*sqrt(2)),
    AngleAndResult.new(720, 0)
);

my @cosines = @sines.map({ AngleAndResult.new($_.angle_in_degrees - 90, $_.result) });

my @sinhes = @sines.grep({ $_.angle_in_degrees < 500 }).map({ AngleAndResult.new($_.angle_in_degrees, 
                                             (exp($_.num(Radians)) - exp(-$_.num(Radians))) / 2.0)});

my @coshes = @sines.grep({ $_.angle_in_degrees < 500 }).map({ AngleAndResult.new($_.angle_in_degrees, 
                                             (exp($_.num(Radians)) + exp(-$_.num(Radians))) / 2.0)});

my @official_bases = (Radians, Degrees, Gradians, Circles);

# cotan tests

for @sines -> $angle
{
    	next if abs(sin($angle.num('radians'))) < 1e-6; 	my $desired_result = cos($angle.num('radians')) / sin($angle.num('radians'));

    # cotan(Num)
    is_approx(cotan($angle.num(Radians)), $desired_result, 
              "cotan(Num) - {$angle.num(Radians)} default");
    for @official_bases -> $base {
        is_approx(cotan($angle.num($base), $base), $desired_result, 
                  "cotan(Num) - {$angle.num($base)} $base");
    }
    
    # cotan(:x(Num))
    is_approx(cotan(:x($angle.num(Radians))), $desired_result, 
              "cotan(:x(Num)) - {$angle.num(Radians)} default");
    for @official_bases -> $base {
        is_approx(cotan(:x($angle.num($base)), :base($base)), $desired_result, 
                  "cotan(:x(Num)) - {$angle.num($base)} $base");
    }

    # Num.cotan tests
    is_approx($angle.num(Radians).cotan, $desired_result, 
              "Num.cotan - {$angle.num(Radians)} default");
    for @official_bases -> $base {
        is_approx($angle.num($base).cotan($base), $desired_result, 
                  "Num.cotan - {$angle.num($base)} $base");
    }

    # cotan(Rat)
    is_approx(cotan($angle.rat(Radians)), $desired_result, 
              "cotan(Rat) - {$angle.rat(Radians)} default");
    for @official_bases -> $base {
        is_approx(cotan($angle.rat($base), $base), $desired_result, 
                  "cotan(Rat) - {$angle.rat($base)} $base");
    }

    # cotan(:x(Rat))
    is_approx(cotan(:x($angle.rat(Radians))), $desired_result, 
              "cotan(:x(Rat)) - {$angle.rat(Radians)} default");
    for @official_bases -> $base {
        is_approx(cotan(:x($angle.rat($base)), :base($base)), $desired_result, 
                  "cotan(:x(Rat)) - {$angle.rat($base)} $base");
    }

    # Rat.cotan tests
    is_approx($angle.rat(Radians).cotan, $desired_result, 
              "Rat.cotan - {$angle.rat(Radians)} default");
    for @official_bases -> $base {
        is_approx($angle.rat($base).cotan($base), $desired_result, 
                  "Rat.cotan - {$angle.rat($base)} $base");
    }

    # cotan(Int)
    is_approx(cotan($angle.int(Degrees), Degrees), $desired_result, 
              "cotan(Int) - {$angle.int(Degrees)} degrees");
    is_approx($angle.int(Degrees).cotan(Degrees), $desired_result, 
              "Int.cotan - {$angle.int(Degrees)} degrees");

    # Complex tests
    my Complex $zp0 = $angle.complex(0.0, Radians);
    my Complex $sz0 = $desired_result + 0i;
    my Complex $zp1 = $angle.complex(1.0, Radians);
    my Complex $sz1 = { cos($_) / sin($_) }($zp1);
    my Complex $zp2 = $angle.complex(2.0, Radians);
    my Complex $sz2 = { cos($_) / sin($_) }($zp2);
    
    # cotan(Complex) tests
    is_approx(cotan($zp0), $sz0, "cotan(Complex) - $zp0 default");
    is_approx(cotan($zp1), $sz1, "cotan(Complex) - $zp1 default");
    is_approx(cotan($zp2), $sz2, "cotan(Complex) - $zp2 default");
    
    for @official_bases -> $base {
        my Complex $z = $angle.complex(0.0, $base);
        is_approx(cotan($z, $base), $sz0, "cotan(Complex) - $z $base");
    
        $z = $angle.complex(1.0, $base);
        is_approx(cotan($z, $base), $sz1, "cotan(Complex) - $z $base");
                        
        $z = $angle.complex(2.0, $base);
        is_approx(cotan($z, $base), $sz2, "cotan(Complex) - $z $base");
    }
    
    # Complex.cotan tests
    is_approx($zp0.cotan, $sz0, "Complex.cotan - $zp0 default");
    is_approx($zp1.cotan, $sz1, "Complex.cotan - $zp1 default");
    is_approx($zp2.cotan, $sz2, "Complex.cotan - $zp2 default");
    
    for @official_bases -> $base {
        my Complex $z = $angle.complex(0.0, $base);
        is_approx($z.cotan($base), $sz0, "Complex.cotan - $z $base");
    
        $z = $angle.complex(1.0, $base);
        is_approx($z.cotan($base), $sz1, "Complex.cotan - $z $base");
    
        $z = $angle.complex(2.0, $base);
        is_approx($z.cotan($base), $sz2, "Complex.cotan - $z $base");
    }
}

is(cotan(Inf), NaN, "cotan(Inf) - default");
is(cotan(-Inf), NaN, "cotan(-Inf) - default");
for @official_bases -> $base
{
    is(cotan(Inf,  $base), NaN, "cotan(Inf) - $base");
    is(cotan(-Inf, $base), NaN, "cotan(-Inf) - $base");
}
        

# acotan tests

for @sines -> $angle
{
    	next if abs(sin($angle.num('radians'))) < 1e-6; 	my $desired_result = cos($angle.num('radians')) / sin($angle.num('radians'));

    # acotan(Num) tests
    is_approx(cotan(acotan($desired_result)), $desired_result, 
              "acotan(Num) - {$angle.num(Radians)} default");
    for @official_bases -> $base {
        is_approx(cotan(acotan($desired_result, $base), $base), $desired_result, 
                  "acotan(Num) - {$angle.num($base)} $base");
    }
    
    # acotan(:x(Num))
    is_approx(cotan(acotan(:x($desired_result))), $desired_result, 
              "acotan(:x(Num)) - {$angle.num(Radians)} default");
    for @official_bases -> $base {
        is_approx(cotan(acotan(:x($desired_result), 
                                                           :base($base)), 
                                  $base), $desired_result, 
                  "acotan(:x(Num)) - {$angle.num($base)} $base");
    }
    
    # Num.acotan tests
    is_approx($desired_result.Num.acotan.cotan, $desired_result, 
              "Num.acotan - {$angle.num(Radians)} default");
    for @official_bases -> $base {
        is_approx($desired_result.Num.acotan($base).cotan($base), $desired_result,
                  "Num.acotan - {$angle.num($base)} $base");
    }
    
    # acotan(Complex) tests
    for ($desired_result + 0i, $desired_result + .5i, $desired_result + 2i) -> $z {
        is_approx(cotan(acotan($z)), $z, 
                  "acotan(Complex) - {$angle.num(Radians)} default");
        for @official_bases -> $base {
            is_approx(cotan(acotan($z, $base), $base), $z, 
                      "acotan(Complex) - {$angle.num($base)} $base");
        }
        is_approx($z.acotan.cotan, $z, 
                  "Complex.acotan - {$angle.num(Radians)} default");
        for @official_bases -> $base {
            is_approx($z.acotan($base).cotan($base), $z, 
                      "Complex.acotan - {$angle.num($base)} $base");
        }
    }
}

for (-2/2, -1/2, 1/2, 2/2) -> $desired_result
{
    # acotan(Rat) tests
    is_approx(cotan(acotan($desired_result)), $desired_result, 
              "acotan(Rat) - $desired_result default");
    for @official_bases -> $base {
        is_approx(cotan(acotan($desired_result, $base), $base), $desired_result, 
                  "acotan(Rat) - $desired_result $base");
    }
    
    # Rat.acotan tests
    is_approx($desired_result.acotan.cotan, $desired_result, 
              "Rat.acotan - $desired_result default");
    for @official_bases -> $base {
        is_approx($desired_result.acotan($base).cotan($base), $desired_result,
                  "Rat.acotan - $desired_result $base");
    }
    
    next unless $desired_result.denominator == 1;
    
    # acotan(Int) tests
    is_approx(cotan(acotan($desired_result.numerator)), $desired_result, 
              "acotan(Int) - $desired_result default");
    for @official_bases -> $base {
        is_approx(cotan(acotan($desired_result.numerator, $base), $base), $desired_result, 
                  "acotan(Int) - $desired_result $base");
    }
    
    # Int.acotan tests
    is_approx($desired_result.numerator.acotan.cotan, $desired_result, 
              "Int.acotan - $desired_result default");
    for @official_bases -> $base {
        is_approx($desired_result.numerator.acotan($base).cotan($base), $desired_result,
                  "Int.acotan - $desired_result $base");
    }
}
        
done_testing;

# vim: ft=perl6 nomodifiable
