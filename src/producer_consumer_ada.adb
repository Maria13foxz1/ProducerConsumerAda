with Ada.Text_IO, GNAT.Semaphores;
use Ada.Text_IO, GNAT.Semaphores;

with Ada.Containers.Indefinite_Doubly_Linked_Lists;
use Ada.Containers;

procedure Producer_Consumer_Ada is
   package String_Lists is new Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;

   procedure Starter (Storage_Size : in Integer) is
      Storage : List;
      Full_Storega   : Counting_Semaphore (Storage_Size, Default_Ceiling);
      Empty_Storega  : Counting_Semaphore (0, Default_Ceiling);
      Free_Storega: Counting_Semaphore (1, Default_Ceiling);

      task type Consumer is
         entry Start(Item_Numbers:Integer);
      end;

      task type Producer is
         entry Start(Item_Numbers:Integer);
      end;

      task body Producer is
           Item_Numbers : Integer;
      begin
           accept Start (Item_Numbers : in Integer) do
              Producer.Item_Numbers := Item_Numbers;
           end Start;

         for i in 1 .. Item_Numbers loop
            Full_Storega.Seize;
            Free_Storega.Seize;

            Storage.Append ("item " & i'Img);
            Put_Line ("Producer add" & i'Img);

            Free_Storega.Release;
            Empty_Storega.Release;
            delay 0.1;
         end loop;

      end Producer;

      task body Consumer is
         Item_Numbers : Integer;
      begin
           accept Start (Item_Numbers : in Integer) do
              Consumer.Item_Numbers := Item_Numbers;
           end Start;

         for i in 1 .. Item_Numbers loop
            Empty_Storega.Seize;
            Free_Storega.Seize;

            declare
               item : String := First_Element (Storage);
            begin
               Put_Line ("Consumer get " & item);
            end;

            Storage.Delete_First;

            Free_Storega.Release;
            Full_Storega.Release;

            delay 0.3;
         end loop;

      end Consumer;

      Num_Consumers : constant := 3;
      Num_Producers : constant := 2;

      Consumers : array (1..Num_Consumers) of Consumer;
      Producers : array (1..Num_Producers) of Producer;
      Items_to_add_consumer: array(1..Num_Consumers) of Integer := (4, 5, 6);
      Items_to_add_producer: array(1..Num_Producers) of Integer := (7,8);

      begin
         for i in Consumers'Range loop
            Consumers(i).Start(Items_to_add_consumer(i));
         end loop;

         for i in Producers'Range loop
            Producers(i).Start(Items_to_add_producer(i));
         end loop;
      end Starter;

begin
   Starter (7);
end Producer_Consumer_Ada;
