:- ['ev3dev.pl'].

:- dynamic(device_path/3).
:- dynamic(detect_port/3).

% Write Base ops
file_write(File, Content) :-
  open(File, write, Stream),
  write(Stream, Content),
  flush_output(Stream),
  catch(close(Stream), _, true).

file_read(File, Content) :-
  open(File, read, Stream),
  read_line_to_codes(Stream, Codes),
  atom_codes(Ca, Codes),
  ( atom_number(Ca, Content);
    Content = Ca % try to split this up for list-like results
  ),
  catch(close(Stream), _, true).

try_split_list(String, Result) :-
  String = Result.

device_path(Port, Basepath, DevicePath) :-
  port_symbol(Port, Symbol),
  atomic_concat(Basepath, '*/address', Template),
  expand_(Template, AddressFile),
  file_read(AddressFile, Content), Content = Symbol, !,
  file_directory_name(AddressFile, DevicePath),
  asserta(
    device_path(Port, Basepath, DevicePath) :-
      exists_directory(DevicePath);
      (retract(device_path(Port, Basepath, DevicePath)), fail)
  ).

detect_port(Port, Prefix, DriverName) :-
  atomic_concat(Prefix, '*/', Template),
  expand_(Template, Basepath),
  atomic_concat(Basepath, '/address', AddressFile),
  atomic_concat(Basepath, '/driver_name', DriverFile),
  file_read(DriverFile, DriverName),
  file_read(AddressFile, Port),
  asserta(
    detect_port(Port, Prefix, DriverName) :-
      exists_directory(Basepath);
      (retract(detect_port(Port, Prefix, DriverName)), fail)
  ).

%! expand_(+F:Wildcard, -E:Path) is nondet
%
% expand a wildcard pattern and return one match
%
% @arg F wildcard pattern
% @arg E single path matching wildcard
expand_(F, E) :-
  expand_file_name(F, L),
  member(E, L).
