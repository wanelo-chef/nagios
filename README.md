# nagios-cookbook

TODO: Enter the cookbook description here.

## Supported Platforms

TODO: List your supported platforms.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['nagios']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### nagios::default

Include `nagios` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[nagios::default]"
  ]
}
```

## License and Authors

Author:: Wanelo, Inc. (<dev@wanelo.com>)
