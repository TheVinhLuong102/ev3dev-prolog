:- ['../fileaccess.pl'].

light_sensor(P) :- lego_sensor(P, 'lego-ev3-color').
ultrasonic_sensor(P) :- lego_sensor(P, 'lego-ev3-us').
gyro_sensor(P) :- lego_sensor(P, 'lego-ev3-gyro').
touch_sensor(P) :- lego_sensor(P, 'lego-ev3-touch').

lego_sensor(Port) :-
  lego_sensor(Port, _).

lego_sensor(Port, Type, Path) :-
  subsystem_detect(Port, Type, Path, '/sys/class/lego-sensor/sensor*').

lego_sensor(Port, Type) :-
  lego_sensor(Port, Type, _).

col_ambient(Port, Val) :-
  light_sensor(Port),
  mode(Port, 'COL-AMBIENT'),
  value(Port, 0, Val).

col_reflect(Port, Val) :-
  light_sensor(Port),
  mode(Port, 'COL-REFLECT'),
  value(Port, 0, Val).

col_color(Port, Val) :-
  light_sensor(Port),
  mode(Port, 'COL-COLOR'),
  value(Port, 0, Val).

%mit Liste
col_rgb_raw(Port, [R, G, B]) :-
  col_rgb_raw(Port, R, G, B).
%mit drei Werten
col_rgb_raw(Port, R, G, B) :-
  light_sensor(Port),
  mode(Port, 'RGB-RAW'),
  value(Port, 0, R),
  value(Port, 1, G),
  value(Port, 2, B).

gyro_ang(Port, Val) :-
  gyro_sensor(Port),
  mode(Port, 'GYRO-G&A'),
  value(Port, 0, Val).

gyro_rate(Port, Val) :-
  gyro_sensor(Port),
  mode(Port, 'GYRO-G&A'),
  value(Port, 1, Val).

gyro_reset(Port) :-
  gyro_sensor(Port),
  mode(Port, 'GYRO-ANG'),
  mode(Port, 'GYRO-G&A').


adjust_val(Port, RawVal, ValAdjusted) :-
  decimals(Port, Decimals),
  ValAdjusted is RawVal / 10.0**Decimals.

us_dist_cm(Port, Val) :-
  ultrasonic_sensor(Port),
  mode(Port, 'US-DIST-CM'),
  value(Port, 0, RawVal),
  adjust_val(Port, RawVal, Val).

us_dist_inches(Port, Val) :-
  ultrasonic_sensor(Port),
  mode(Port, 'US-DIST-IN'),
  value(Port, 0, RawVal),
  adjust_val(Port, RawVal, Val).

us_listen(Port, Val) :-
  ultrasonic_sensor(Port),
  mode(Port, 'US-LISTEN'),
  value(Port, 0, Val).

touch(Port, Val) :-
  touch_sensor(Port),
  mode(Port, 'TOUCH'),
  value(Port, 0, Val).

decimals(Port, Decimals) :-
  decimals_file(Port, File),
  file_read(File, Decimals).

decimals_file(Port, File) :-
  lego_sensor(Port, _, Basepath),
  atomic_concat(Basepath, '/decimals', File).

mode_file(Port, File) :-
  lego_sensor(Port, _, Basepath),
  atomic_concat(Basepath, '/mode', File).

value_file(Port, ValueNum, File) :-
  lego_sensor(Port, _, Basepath),
  atomic_concat(Basepath, '/value', BaseValuePath),
  atomic_concat(BaseValuePath, ValueNum, File).

value(Port, ValueNum, Value) :-
  value_file(Port, ValueNum, File),
  file_read(File, Value).

mode(D, C) :-
  nonvar(C),
  mode_file(D, F),
  file_write(F, C).

mode(D, C) :-
  var(C),
  mode_file(D, F),
  file_read(F, C).
