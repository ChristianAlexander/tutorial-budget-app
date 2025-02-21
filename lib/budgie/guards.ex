defmodule Budgie.Guards do
  defguard is_uuid(value)
           when is_binary(value) and byte_size(value) == 36 and
                  binary_part(value, 1, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 2, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 3, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 4, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 5, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 6, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 7, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 8, 1) == "-" and
                  binary_part(value, 9, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 10, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 11, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 12, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 13, 1) == "-" and
                  binary_part(value, 14, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 15, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 16, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 17, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 18, 1) == "-" and
                  binary_part(value, 19, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 20, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 21, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 22, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 23, 1) == "-" and
                  binary_part(value, 24, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 25, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 26, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 27, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 28, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 29, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 30, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 31, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 32, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 33, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 34, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F| and
                  binary_part(value, 35, 1) in ~w|0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F|
end
