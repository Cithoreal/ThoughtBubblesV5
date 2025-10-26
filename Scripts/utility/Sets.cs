using Godot;
using Godot.Collections;

namespace ThoughtBubblesV5.Scripts
{
	[Tool]
	public partial class Sets
	{
		public Array IntersectArrays(Array array1, Array array2)
		{
			Array result = new();
			foreach (var item in array1)
			{
				if (array2.Contains(item))
				{
					result.Add(item);
				}
			}
			return result;
		}
	}
}
