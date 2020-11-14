using System;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace ConsoleApp23
{
    class Program
    {
        private static int[] A;
        private static int[] B;
        private static int[] C;
        private static bool ans1 = true;
        private static bool ans2 = true;
        private static bool ans3 = true;
        private static bool ans4 = true;
        private static readonly Random rnd = new Random();

        static void Main(string[] args)
        {
            //Генерация множеств, в данной задачи для удобства проверки все генерируется рандомно,
            // причем всего может быть максимум 3 числа в множестве(это сделано для того, чтобы тру выпадали почаще)
            SetGeneration();
            // Обычный запуск методов для проверки множеств, это нужно для сравнения скорости
            // Также в каждом методе проверки множест стоит пауза потоков, чтобы нагляднее можно было понять, насколько потоки быстрее работают
            Methods();
            //https://ru.stackoverflow.com/questions/548876/%D0%92-%D1%87%D0%B5%D0%BC-%D1%80%D0%B0%D0%B7%D0%BD%D0%B8%D1%86%D0%B0-%D0%BC%D0%B5%D0%B6%D0%B4%D1%83-task-%D0%B8-thread-%D0%B8-%D0%BA%D0%BE%D0%B3%D0%B4%D0%B0-%D1%87%D1%82%D0%BE-%D0%BB%D1%83%D1%87%D1%88%D0%B5-%D0%B8%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D1%82%D1%8C
            // В данной дз требуется скорее именно класс Thread нежели Task, но оба класса относятся к параллельному 
            // программированию, но Task работает чуть хитрее, к примеру 1000 тасков может иметь всего 10 потоков,
            // в данной задаче они примерно одинаково работают по скорости, но в продакшене я бы сейчас использовал только
            // таски, т.к. это более новая и оптимизированная вещь
            Threads();
            Tasks();
            Console.ReadKey();
        }

        /// <summary>
        /// Вызов генератора для каждого множества
        /// </summary>
        public static void SetGeneration()
        {
            GenerateA();
            GenerateB();
            GenerateC();
        }

        /// <summary>
        /// Решение задачи банальным вызовом методов
        /// </summary>
        public static void Methods()
        {
            Stopwatch sw1 = new Stopwatch();
            sw1.Start();
            AuB();
            AnB();
            A_B();
            B_A();
            sw1.Stop();
            Console.WriteLine();
            Console.WriteLine("Обычный вызов методов");
            Console.WriteLine(sw1.ElapsedMilliseconds + " ms");
            Console.WriteLine();
            Console.WriteLine("AuB - " + ans1);
            Console.WriteLine("AnB - " + ans2);
            Console.WriteLine("A/B - " + ans3);
            Console.WriteLine("A/B - " + ans4);
            ans1 = true;
            ans2 = true;
            ans3 = true;
            ans4 = true;
            Console.WriteLine();
        }

        /// <summary>
        /// Решение задачи с помощью потоков, где каждая проверка имеет отдельный поток(всего 4),
        /// таким образом в задаче всего 5 потоков(1 главный)
        /// https://metanit.com/sharp/tutorial/11.1.php
        /// </summary>
        public static void Threads()
        {
            Console.WriteLine("Потоки");

            Stopwatch sw2 = new Stopwatch();
            Thread t1 = new Thread(AuB);
            Thread t2 = new Thread(AnB);
            Thread t3 = new Thread(A_B);
            Thread t4 = new Thread(B_A);
            sw2.Start();
            t1.Start();
            t2.Start();
            t3.Start();
            t4.Start();
            // Join служит для ожидания завершения потока(т.е. главный поток, ожидает завершения каждого потока,
            // прежде чем продолжить)
            t1.Join();
            t2.Join();
            t3.Join();
            t4.Join();
            sw2.Stop();
            Console.WriteLine(sw2.ElapsedMilliseconds + " ms");
            Console.WriteLine();
            Console.WriteLine("AuB - " + ans1);
            Console.WriteLine("AnB - " + ans2);
            Console.WriteLine("A/B - " + ans3);
            Console.WriteLine("A/B - " + ans4);
            ans1 = true;
            ans2 = true;
            ans3 = true;
            ans4 = true;
            Console.WriteLine();
        }

        /// <summary>
        /// Аналогичное разбиение на таски как и с тредами
        /// </summary>
        public static void Tasks()
        {
            Console.WriteLine("Таски");

            Stopwatch sw3 = new Stopwatch();
            sw3.Start();
            Task[] tasks =
            {
                new Task(AuB),
                new Task(AnB),
                new Task(A_B),
                new Task(B_A),
            };
            foreach (var t in tasks)
            {
                t.Start();
            }
            //Ожидаем выполнение всех потоков
            //https://metanit.com/sharp/tutorial/12.1.php
            Task.WaitAll(tasks);
            sw3.Stop();
            Console.WriteLine(sw3.ElapsedMilliseconds + " ms");
            Console.WriteLine();
            Console.WriteLine("AuB - " + ans1);
            Console.WriteLine("AnB - " + ans2);
            Console.WriteLine("A/B - " + ans3);
            Console.WriteLine("A/B - " + ans4);
        }

        //В следующих 3 методах используется linq для сортировки и другой работы с массивами
        //https://metanit.com/sharp/tutorial/15.1.php
        public static void GenerateA()
        {
            int len = 3;
            A = new int[len];
            for (int i = 0; i < len; i++)
            {
                A[i] = rnd.Next(1, 4);
            }
            A = A.OrderBy(x => x).Distinct().ToArray();
            Console.WriteLine("A:");
            foreach (var item in A)
            {
                Console.Write(item + " ");
            }
            Console.WriteLine();
        }

        public static void GenerateB()
        {
            int len = 3;
            B = new int[len];
            for (int i = 0; i < len; i++)
            {
                B[i] = rnd.Next(1, 4);
            }
            B = B.OrderBy(x => x).Distinct().ToArray();
            Console.WriteLine("B:");
            foreach (var item in B)
            {
                Console.Write(item + " ");
            }
            Console.WriteLine();
        }

        public static void GenerateC()
        {
            int len = 3;
            C = new int[len];
            for (int i = 0; i < len; i++)
            {
                C[i] = rnd.Next(1, 4);
            }

            C = C.OrderBy(x => x).Distinct().ToArray();
            Console.WriteLine("C:");
            foreach (var item in C)
            {
                Console.Write(item + " ");
            }
            Console.WriteLine();
        }

        // В следующих 4 методах используются методы для работы c объединением, пересечением и разностью коллекций
        //https://metanit.com/sharp/tutorial/15.4.php
        public static void AuB()
        {
            
            ans1 = C.SequenceEqual(A.Union(B).OrderBy(x => x).ToArray());
            Thread.Sleep(100);
            
        }

        public static void AnB()
        {
            ans2 = C.SequenceEqual(A.Intersect(B).OrderBy(x => x).ToArray());
            Thread.Sleep(100);
        }

        public static void A_B()
        {
            ans3 = C.SequenceEqual(A.Except(B).OrderBy(x => x).ToArray());
            Thread.Sleep(100);
        }

        public static void B_A()
        {
            ans4 = C.SequenceEqual(B.Except(A).OrderBy(x => x).ToArray());
            Thread.Sleep(100);
        }
    }
}
