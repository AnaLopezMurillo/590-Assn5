defmodule Barbershop do 
    # Define the consts
    chairs = 6  
    num_waiting = 0
    barber_busy = 0     # 0 for free, 1 for busy

    def start do
        # something here to initialize start # of customers and add to waiting room list, and spawn barber

    defp barber() do
        IO.puts("The barber is sleeping...")
    end

    defp cuthair(id) do
        IO.puts("Barber is cutting hair.")
        :timer.sleep(:rand.uniform(1000))
    end

    defp run_receptionist(id) do

        # check if barber is available

        if num_waiting == 0 do
            IO.puts("Serving customer #{id}.")
            cuthair(id)
        else if chairs > 0 do
            IO.puts("Customer #{id} sent to waiting room.")
            chairs = chairs - 1
        else 
            IO.puts("No chairs available, customer #{id} sent away.")

        IO.puts("")
        :timer.sleep(:rand.uniform(1000))
    end

    defp spawncustomer() do
        # spawn a customer process here, send to receptionist

    def loop() do
        # this is the main run function
         IO.puts("Starting the barbershop!")

         # need to add some sort of process that keeps spawning customers at random times 

    end
end