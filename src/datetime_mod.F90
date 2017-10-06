module datetime_mod

  use timedelta_mod

  implicit none

  private

  public datetime
  public datetime_type
  public days_of_month
  public days_of_year
  public is_leap_year

  type datetime_type
    integer :: year = 0
    integer :: month = 1
    integer :: day = 1
    integer :: hour = 0
    integer :: minute = 0
    integer :: second = 0
    integer :: millisecond = 0
    real(8) :: timezone = 0.0d0
  contains
    procedure :: isoformat
    procedure :: add_months
    procedure :: add_days
    procedure :: add_hours
    procedure :: add_minutes
    procedure :: add_seconds
    procedure :: add_milliseconds
    procedure, private :: assign
    procedure, private :: add
    procedure, private :: eq
    generic :: assignment(=) => assign
    generic :: operator(+) => add
    generic :: operator(==) => eq
  end type datetime_type

contains

  elemental type(datetime_type) function datetime(year, month, day, hour, minute, second, millisecond, timezone)

    integer, intent(in), optional :: year
    integer, intent(in), optional :: month
    integer, intent(in), optional :: day
    integer, intent(in), optional :: hour
    integer, intent(in), optional :: minute
    integer, intent(in), optional :: second
    integer, intent(in), optional :: millisecond
    real(8), intent(in), optional :: timezone

    if (present(year))        datetime%year        = year
    if (present(month))       datetime%month       = month
    if (present(day))         datetime%day         = day
    if (present(hour))        datetime%hour        = hour
    if (present(minute))      datetime%minute      = minute
    if (present(second))      datetime%second      = second
    if (present(millisecond)) datetime%millisecond = millisecond
    if (present(timezone))    datetime%timezone    = timezone

  end function datetime

  function isoformat(this) result(res)

    class(datetime_type), intent(in) :: this
    character(30) res

    write(res, "(I4.4, '-', I2.2, '-', I2.2, 'T', I2.2, ':', I2.2, ':', I2.2, 'Z')") &
      this%year, this%month, this%day, this%hour, this%minute, this%second

  end function isoformat

  pure subroutine add_months(this, months)

    class(datetime_type), intent(inout) :: this
    integer, intent(in) :: months

    this%month = this%month + months

    if (this%month > 12) then
      this%year = this%year + this%month / 12
      this%month = mod(this%month, 12)
    else if (this%month < 1) then
      this%year = this%year - this%month / 12 - 1
      this%month = mod(this%month, 12) + 1
    end if

  end subroutine add_months

  pure subroutine add_days(this, days)

    class(datetime_type), intent(inout) :: this
    integer, intent(in) :: days

    integer month_days

    this%day = this%day + days

    do
      month_days = days_of_month(this%year, this%month)
      if (this%day > month_days) then
        call this%add_months(1)
        this%day = this%day - month_days
      else if (this%day < 1) then
        call this%add_months(-1)
        this%day = this%day + month_days
      else
        exit
      end if      
    end do

  end subroutine add_days

  pure subroutine add_hours(this, hours)

    class(datetime_type), intent(inout) :: this
    integer, intent(in) :: hours

    this%hour = this%hour + hours

    do
      if (this%hour >= 24) then
        call this%add_days(this%hour / 24)
        this%hour = mod(this%hour, 24)
      else if (this%hour < 0) then
        call this%add_days(this%hour / 24 - 1)
        this%hour = mod(this%hour, 24) + 24
      else
        exit
      end if
    end do

  end subroutine add_hours

  pure subroutine add_minutes(this, minutes)

    class(datetime_type), intent(inout) :: this
    integer, intent(in) :: minutes

    this%minute = this%minute + minutes

    do
      if (this%minute >= 60) then
        call this%add_hours(this%minute / 60)
        this%minute = mod(this%minute, 60)
      else if (this%minute < 0) then
        call this%add_hours(this%minute / 60 - 1)
        this%minute = mod(this%minute, 60) + 60
      else
        exit
      end if
    end do

  end subroutine add_minutes

  pure subroutine add_seconds(this, seconds)

    class(datetime_type), intent(inout) :: this
    integer, intent(in) :: seconds

    this%second = this%second + seconds

    do
      if (this%second >= 60) then
        call this%add_minutes(this%second / 60)
        this%second = mod(this%second, 60)
      else if (this%second < 0) then
        call this%add_minutes(this%second / 60 - 1)
        this%second = mod(this%second, 60) + 60
      else
        exit
      end if
    end do

  end subroutine add_seconds

  pure subroutine add_milliseconds(this, milliseconds)

    class(datetime_type), intent(inout) :: this
    integer, intent(in) :: milliseconds

    this%millisecond = this%millisecond + milliseconds

    do
      if (this%millisecond >= 1000) then
        call this%add_seconds(this%millisecond / 1000)
        this%millisecond = mod(this%millisecond, 1000)
      else if (this%millisecond < 0) then
        call this%add_seconds(this%millisecond / 1000 - 1)
        this%millisecond = mod(this%millisecond, 1000) + 1000
      else
        exit
      end if
    end do

  end subroutine add_milliseconds

  pure elemental subroutine assign(this, other)

    class(datetime_type), intent(inout) :: this
    class(datetime_type), intent(in) :: other

    this%year        = other%year
    this%month       = other%month
    this%day         = other%day
    this%hour        = other%hour
    this%minute      = other%minute
    this%second      = other%second
    this%millisecond = other%millisecond

  end subroutine assign

  elemental type(datetime_type) function  add(this, td) result(res)

    class(datetime_type), intent(in) :: this
    class(timedelta_type), intent(in) :: td

    res = this
    call res%add_milliseconds(td%milliseconds)
    call res%add_seconds(td%seconds)
    call res%add_minutes(td%minutes)
    call res%add_hours(td%hours)
    call res%add_days(td%days)

  end function add

  elemental logical function eq(this, other)

    class(datetime_type), intent(in) :: this
    class(datetime_type), intent(in) :: other

    eq = this%year        == other%year   .and. &
         this%month       == other%month  .and. &
         this%day         == other%day    .and. &
         this%hour        == other%hour   .and. &
         this%minute      == other%minute .and. &
         this%second      == other%second .and. &
         this%millisecond == other%millisecond

  end function eq

  pure integer function days_of_month(year, month) result(res)

    integer, intent(in) :: year
    integer, intent(in) :: month

    integer, parameter :: days(12) = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    if (month == 2 .and. is_leap_year(year)) then
      res = 29
    else
      res = days(month)
    end if

  end function days_of_month

  pure integer function days_of_year(year) result(res)

    integer, intent(in) :: year

    if (is_leap_year(year)) then
      res = 366
    else
      res = 365
    end if

  end function days_of_year

  pure logical function is_leap_year(year) result(res)

    integer, intent(in) :: year

    res = (mod(year, 4) == 0 .and. .not. mod(year, 100) == 0) .or. (mod(year, 400) == 0)

  end function is_leap_year

end module datetime_mod