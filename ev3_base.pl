% import subsystems
:- use_module(library(lists)).
:- ['lib/subsystems/dc-motor.pl',
 'lib/subsystems/lego-sensor.pl',
 'lib/subsystems/servo-motor.pl',
 'lib/subsystems/tacho-motor.pl'].

motor_start(M) :-
 tacho_motor(M),
 command(M, 'run-forever').

motor_stop(M) :-
 tacho_motor(M),
 speed_sp(M, 0),
 command(M, 'stop').

stop_all_motors :-
 foreach(tacho_motor(M), motor_stop(M)).

motor_run(Motor, Speed) :-
 speed_adjust(Speed, Motor, CSpeed),
 run_forever(Motor, CSpeed).

motor_run(Motor, Speed, Angle) :-
 speed_adjust(Speed, Motor, CSpeed),
 speed_sp(Motor, CSpeed),
 position_sp(Motor, Angle),
 command(Motor, 'run-to-rel-pos'),
 motor_wait_while(Motor, 'running').

motor_wait_while(Motor, State) :-
 tacho_motor(Motor),
 memberchk(State, ['running', 'ramping', 'holding', 'overloaded', 'stalled']),
 repeat,
 state(Motor, States),
 \+ memberchk(State, States),!.

motor_wait_until(Motor, State) :-
 tacho_motor(Motor),
 memberchk(State, ['running', 'ramping', 'holding', 'overloaded', 'stalled']),
 repeat,
 state(Motor, States),
 memberchk(State, States),!.

run_forever(Motor, Speed) :-
 tacho_motor(Motor),
 speed_sp(Motor, Speed),
 command(Motor, 'run-forever').
