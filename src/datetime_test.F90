program datetime_test

  use unit_test
  use datetime_mod
  use timedelta_mod

  implicit none

  type(datetime_type) a, b
  type(timedelta_type) dt

  call test_case_init()

  call test_case_create('Test datetime type')

  ! Test constructor function.
  a = datetime(2017, 10, 6, 12, 31, 23)
  call assert_equal(a%year, 2017)
  call assert_equal(a%month, 10)
  call assert_equal(a%day, 6)
  call assert_equal(a%hour, 12)
  call assert_equal(a%minute, 31)
  call assert_equal(a%second, 23)
  call assert_equal(a%millisecond, 0)
  call assert_approximate(a%timezone, 0.0)
  call assert_equal(a%isoformat(), '2017-10-06T12:31:23Z')

  a = datetime('2018041401', '%Y%m%d%H')
  call assert_equal(a%isoformat(), '2018-04-14T01:00:00Z')

  a = datetime('2018041401', '%x')
  call assert_equal(a%year, -1)
  call assert_equal(a%month, -1)
  call assert_equal(a%day, -1)
  call assert_equal(a%hour, -1)
  call assert_equal(a%minute, -1)
  call assert_equal(a%second, -1)
  call assert_equal(a%millisecond, -1)

  ! Test parse isoformat.
  a = datetime('2018-01-18T11:51:10Z')
  call assert_equal(a%year, 2018)
  call assert_equal(a%month, 1)
  call assert_equal(a%day, 18)
  call assert_equal(a%hour, 11)
  call assert_equal(a%minute, 51)
  call assert_equal(a%second, 10)
  call assert_equal(a%millisecond, 0)
  call assert_approximate(a%timezone, 0.0)

  ! Test assignment and equal judgement.
  b = a
  call assert_true(a == b)

  ! Test timedelta operators and judgements.
  dt = timedelta(minutes=5)

  b = a + dt
  call assert_true(b > a)
  call assert_true(b >= a)
  call assert_true(a < b)
  call assert_true(a <= b)
  call assert_true(a /= b)
  call assert_equal(a%minute + 5, b%minute)

  b = a - dt
  call assert_true(b < a)
  call assert_true(b <= a)
  call assert_true(a > b)
  call assert_true(a >= b)
  call assert_true(a /= b)
  call assert_equal(a%minute - 5, b%minute)

  a = datetime(2018, 1, 18, 13, 14, 12)
  b = datetime(2018, 1, 13, 12, 45, 13)
  call assert_true(a > b)

  ! Test construction from minute and hour.
  a = datetime(minute=6)
  b = datetime(hour=1)
  call assert_false(a > b)

  a = datetime(minute=56)

  b = a + dt
  call assert_equal(b%hour, 1)
  call assert_equal(b%minute, 1)

  a = datetime(second=45)
  dt = timedelta(seconds=30)
  b = a + dt
  call assert_equal(b%minute, 1)
  call assert_equal(b%second, 15)

  ! Test timedelta days.
  dt = timedelta(days=31)
  a = datetime()
  b = a - dt
  call assert_equal(b%year, 0)
  call assert_equal(b%month, 12)
  call assert_equal(b%day, 1)
  call assert_equal(b%hour, 0)
  call assert_equal(b%minute, 0)
  call assert_equal(b%second, 0)
  call assert_equal(b%millisecond, 0)

  dt = timedelta(days=37)
  a = datetime()
  b = a - dt
  call assert_equal(b%year, 0)
  call assert_equal(b%month, 11)
  call assert_equal(b%day, 25)
  call assert_equal(b%hour, 0)
  call assert_equal(b%minute, 0)
  call assert_equal(b%second, 0)
  call assert_equal(b%millisecond, 0)

  ! Test timedelta hours.
  dt = timedelta(hours=25)
  a = datetime()
  b = a - dt
  call assert_equal(b%year, 0)
  call assert_equal(b%month, 12)
  call assert_equal(b%day, 30)
  call assert_equal(b%hour, 23)
  call assert_equal(b%minute, 0)
  call assert_equal(b%second, 0)
  call assert_equal(b%millisecond, 0)

  dt = timedelta(hours=24)
  a = datetime()
  b = a - dt
  call assert_equal(b%year, 0)
  call assert_equal(b%month, 12)
  call assert_equal(b%day, 31)
  call assert_equal(b%hour, 0)
  call assert_equal(b%minute, 0)
  call assert_equal(b%second, 0)
  call assert_equal(b%millisecond, 0)

  ! Test timedelta minutes.
  dt = timedelta(minutes=60)
  a = datetime()
  b = a - dt
  call assert_equal(b%year, 0)
  call assert_equal(b%month, 12)
  call assert_equal(b%day, 31)
  call assert_equal(b%hour, 23)
  call assert_equal(b%minute, 0)
  call assert_equal(b%second, 0)
  call assert_equal(b%millisecond, 0)

  ! Test timedelta seconds.
  dt = timedelta(seconds=21600)
  a = datetime()
  b = a - dt
  call assert_equal(b%year, 0)
  call assert_equal(b%month, 12)
  call assert_equal(b%day, 31)
  call assert_equal(b%hour, 18)
  call assert_equal(b%minute, 0)
  call assert_equal(b%second, 0)
  call assert_equal(b%millisecond, 0)

  ! Test timedelta milliseconds.
  dt = timedelta(milliseconds=2200)
  a = datetime(millisecond=300)
  b = a + dt
  call assert_equal(b%year, 1)
  call assert_equal(b%month, 1)
  call assert_equal(b%day, 1)
  call assert_equal(b%hour, 0)
  call assert_equal(b%minute, 0)
  call assert_equal(b%second, 2)
  call assert_equal(b%millisecond, 500)

  dt = timedelta(milliseconds=1000)
  a = datetime()
  b = a - dt
  call assert_equal(b%year, 0)
  call assert_equal(b%month, 12)
  call assert_equal(b%day, 31)
  call assert_equal(b%hour, 23)
  call assert_equal(b%minute, 59)
  call assert_equal(b%second, 59)
  call assert_equal(b%millisecond, 0)

  ! Test leap year judgement.
  call assert_false(is_leap_year(2017))
  call assert_true(is_leap_year(2000))
  call assert_true(is_leap_year(2004))
  call assert_true(is_leap_year(2008))
  call assert_true(is_leap_year(2012))
  call assert_true(is_leap_year(2016))

  ! Test construction from days.
  a = datetime(days=120)
  call assert_equal(a%year, 1)
  call assert_equal(a%month, 5)
  call assert_equal(a%day, 1)
  call assert_equal(a%hour, 0)
  call assert_equal(a%minute, 0)

  ! Test add_* subroutines.
  a = datetime(2017, 2, 1)
  call a%add_months(-6)
  call assert_equal(a%year, 2016)
  call assert_equal(a%month, 8)
  call assert_equal(a%day, 1)

  a = datetime(2018, 1, 1, 0, 0, 0)
  b = datetime(2018, 1, 1, 0, 0, 0)
  dt = a - b  
  call assert_equal(dt%days, 0.0)
  call assert_equal(dt%hours, 0.0)
  call assert_equal(dt%minutes, 0.0)
  call assert_equal(dt%seconds, 0.0)
  call assert_equal(dt%milliseconds, 0)

  a = datetime(2018, 1, 18, 13, 14, 12)
  b = datetime(2018, 1, 13, 12, 45, 13)
  dt = a - b
  call assert_equal(dt%milliseconds, 0)
  call assert_equal(dt%seconds, 59.0)
  call assert_equal(dt%minutes, 28.0)
  call assert_equal(dt%hours, 0.0)
  call assert_equal(dt%days, 5.0)

  a = datetime(2018, 1, 18, 0, 0, 0)
  b = datetime(2018, 1, 13, 0, 0, 0)
  dt = a - b
  call assert_equal(dt%milliseconds, 0)
  call assert_equal(dt%seconds, 0.0)
  call assert_equal(dt%minutes, 0.0)
  call assert_equal(dt%hours, 0.0)
  call assert_equal(dt%days, 5.0)

  a = datetime(2017, 2, 18, 13, 37, 20)
  b = datetime(2018, 1, 13, 0, 0, 0)
  dt = a - b
  call assert_equal(dt%milliseconds, 0)
  call assert_equal(dt%seconds, 40.0)
  call assert_equal(dt%minutes, 22.0)
  call assert_equal(dt%hours, 10.0)
  call assert_equal(dt%days, 328.0)

  a = datetime(2018, 4, 18, 13, 37, 20)
  b = datetime(2018, 4, 18, 13, 37, 10)
  dt = a - b
  call assert_equal(dt%milliseconds, 0)
  call assert_equal(dt%seconds, 10.0)
  call assert_equal(dt%minutes, 0.0)
  call assert_equal(dt%hours, 0.0)
  call assert_equal(dt%days, 0.0)

  a = datetime(2018, 4, 18, 13, 37, 0)
  b = datetime(2018, 4, 18, 13, 34, 0)
  dt = a - b
  call assert_equal(dt%milliseconds, 0)
  call assert_equal(dt%seconds, 0.0)
  call assert_equal(dt%minutes, 3.0)
  call assert_equal(dt%hours, 0.0)
  call assert_equal(dt%days, 0.0)

  a = datetime(2018, 4, 18, 13, 0, 0)
  b = datetime(2018, 4, 18, 12, 0, 0)
  dt = a - b
  call assert_equal(dt%milliseconds, 0)
  call assert_equal(dt%seconds, 0.0)
  call assert_equal(dt%minutes, 0.0)
  call assert_equal(dt%hours, 1.0)
  call assert_equal(dt%days, 0.0)

  a = datetime(year=2017, month=10, day=6, hour=14)
  b = datetime(year=2018, month=4, day=16, hour=23, minute=51)
  dt = b - a
  call assert_equal(dt%total_seconds(), 16624260.0)
  call assert_equal(dt%total_minutes(), 16624260.0 / 60.0)
  call assert_equal(dt%total_hours(), 16624260 / 3600.0)
  call assert_equal(dt%total_days(), 16624260 / 86400.0)

  call test_case_report('Test datetime type')

  call test_case_final()

end program datetime_test
