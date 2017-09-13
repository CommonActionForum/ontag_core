defmodule OntagCore.CMS.MediumPostTest do
  use OntagCore.DataCase
  alias OntagCore.CMS.MediumPost
  @moduledoc """
  Tests for `OntagCore.CMS.MediumPost`
  """

  test "Valid data on changeset" do
    params = %{
      title: "Example",
      uri: "http://example.com",
      publishing_date: %DateTime{
        year: 2016, month: 2, day: 29,
        hour: 23, minute: 0, second: 7,
        utc_offset: -14400, std_offset: 0,
        time_zone: "America/Manaus", zone_abbr: "AMT"
      },
      license: "copyright",
      tags: [
        "tag 1"
      ],
      copyright_cesion: true
    }

    changeset = MediumPost.changeset(%MediumPost{}, params)
    assert changeset.valid?
  end

  test "Invalid data on changeset: no title" do
    params = %{
      uri: "http://example.com",
      publishing_date: %DateTime{
        year: 2016, month: 2, day: 29,
        hour: 23, minute: 0, second: 7,
        utc_offset: -14400, std_offset: 0,
        time_zone: "America/Manaus", zone_abbr: "AMT"
      },
      license: "copyright",
      tags: [
        "tag 1"
      ],
      copyright_cesion: true
    }

    changeset = MediumPost.changeset(%MediumPost{}, params)
    assert %{title: ["can't be blank"]} = errors_on(changeset)
  end

  test "Invalid data on changeset: copyright cesion not given" do
    params = %{
      title: "Example",
      uri: "http://example.com",
      publishing_date: %DateTime{
        year: 2016, month: 2, day: 29,
        hour: 23, minute: 0, second: 7,
        utc_offset: -14400, std_offset: 0,
        time_zone: "America/Manaus", zone_abbr: "AMT"
      },
      license: "copyright",
      tags: [
        "tag 1"
      ],
      copyright_cesion: false
    }

    changeset = MediumPost.changeset(%MediumPost{}, params)
    assert %{copyright_cesion: ["must be accepted"]} = errors_on(changeset)
  end
end
