defmodule Sat do
  @moduledoc """
  Documentation for Sat.
  """

  @doc """
  SAT Solver

  ## Examples

  iex> Sat.dpll("p cnf 2 1
    1 -2 0")
  {:sat, [1, 2]}

  """
  def dpll(formula) do
    [head | tail] = String.split(formula, "\n")
    ["p", "cnf", _, _] = head |> String.split(" ") # 使ってない
    cnf = Enum.map(tail, fn line ->
      line
      |> String.split(" ")
      |> Enum.map(fn x -> String.to_integer(x) end)
      |> Enum.filter(fn x -> x != 0 end)
    end)
    IO.inspect("ok")
    spawn(Sat, :solve, [cnf, MapSet.new(), self()])

    receive do
      false -> {:unsat}
      {true, assignment} -> {:sat, MapSet.to_list(assignment)}
      x -> {x}
    end
  end

  def solve(clauses, assignment, parent) do
    a = unit_propagation(clauses, assignment)
    cond do
      a == [] ->
        send(parent, {true, assignment})
      Enum.member?(a, []) ->
        send(parent, false)
      true -> 
        p = select(a)
        if p == nil do
          IO.puts("unexpected")
        else
          spawn(Sat, :solve, [a, MapSet.put(assignment, p), self()])
          spawn(Sat, :solve, [a, MapSet.put(assignment, -p), self()])
          receive do
            false -> receive do
              false -> send(parent, false)
              {true, x} -> send(parent, {true, x})
            end
            {true, x} -> receive do
              _ -> send(parent, {true, x})
            end
          end
        end
    end
  end

  def unit_propagation(clauses, assignment) do
    Enum.filter(clauses, fn clause ->
      !Enum.any?(clause, fn literal ->
        MapSet.member?(assignment, literal)
      end)
    end) |> Enum.map(fn clause ->
      Enum.filter(clause, fn literal ->
        !MapSet.member?(assignment, -literal)
      end)
    end)
  end

  def select(a) do
    a
    |> List.flatten()
    |> List.first()
  end
end
