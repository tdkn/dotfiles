---
name: upscale
description: Photo to 8K; 2/3-pass contextual AI crop enhancement and registered blending.
---

# Upscale

## Input and setup

- Use the uploaded photo as the original source `S`. If it is missing, request
  it before processing.
- Ask for unspecified choices: "2 passes (recommended) or 3? 8K default;
  another resolution?" Wait for the user's choice. Do not ask again for choices
  already supplied.
- Set the pass count `N` to 2 or 3. Set the longest edge `L` to the specified
  resolution, or 8192 pixels by default. Preserve the source aspect ratio.
- Discover available AI image-editing and raster-processing capabilities. If
  either is unavailable, report the missing requirement.
- Use environment-native tools and paths. Create helpers as needed. Preserve
  `S` and write outputs separately.
- Execute the workflow end to end after the user chooses the settings.

## Crop editing

For each crop `C`, perform the edit operation `E(C)`:

1. Inspect the crop.
2. Supply two images to the AI editor in this order: `S` as the original
   context, then `C` as the target crop. Every edit must receive `S`, including
   edits in later passes. Never submit the crop alone.
3. Use the base prompt `Q` below and add only relevant material constraints.
   Request the maximum practical supported resolution and retain the actual
   output dimensions.
4. Run independent calls concurrently where supported. Persist each output,
   its source-coordinate box, and its prompt immediately.

### Base prompt Q

```text
1=original: identity/anatomy/color/light authority. 2=target: return exact crop/framing/geometry.
Reconstruct plausible photographic detail; preserve expression, pose, contours, clothing, genuine imperfections, focus falloff.
Optical clarity; natural edge transitions; spatially varied texture. Repair inherited artifacts.
Skin: irregular pores/fine creases, quiet intervals.
Hair: cohesive groups, selective fibers, natural sparse fringe.
Iris: source color, irregular branching fibers, coherent pupil, restrained reflections.
Textiles: original weave direction/spacing/motifs.
Avoid invented structures/marks, beautification, relighting, halos, ringing, embossed/crosshatched/repeated texture, synthetic grain, blanket sharpening.
```

## Passes

### Pass 1

1. Divide `S` into a 3 by 3 grid of core regions.
2. Pad each side by 20% of the corresponding core dimension, clipping to the
   bounds of `S`. This produces nine overlapping crops.
3. Run `E(C)` on all nine crops.
4. Register and blend the results into `M1` using the assembly procedure below.
5. Resize the assembled `M1` so its longest edge is `L`.

### Pass 2

1. Select 4 to 8 salient regions of interest from `M1`, such as faces, hair,
   hands, objects, or textiles that are present. Exclude low-information
   regions and pad each selected region.
2. Run `E(C)` on each crop with `S` as the original context.
3. Register and blend the results into `M2`.

### Pass 3

Run this pass only when `N` is 3.

1. Select 4 to 8 tighter focal regions from `M2`, such as individual eyes,
   lips, noses, fingers, or material details that are present. Pad each region
   and exclude low-information regions.
2. Run `E(C)` on each crop with `S` as the original context. Keep homologous
   features consistent.
3. Register and blend the results into `M3`.

## Assembly and inspection

- Map recorded crop boxes into the master image. Retain the coordinate frame
  for each box so crops from different passes map correctly.
- Register each result with a global similarity transform first. Apply
  bounded, smooth local correction only where correspondence is reliable.
  Never distort rigid geometry or repeating patterns. Retain prior pixels
  where registration is unreliable.
- Match broad exposure and color without transferring the prior image's fine
  texture.
- Use normalized overlap blending or multiband blending. Feather 15% to 25%
  of each border, reaching zero alpha at interior patch boundaries.
- Preserve native enhanced crops separately from the assembled master.
- Before the next pass, inspect the full image and focal and overlap crops at
  100% scale. Also inspect the final master before export. Repair doubling,
  seams, drift, and texture mismatch.
- Allow at most two targeted retries per defect. If a result is rejected or
  a retry fails, retain prior content and disclose the limitation.

## Export

1. Export the final master `M_N` as a lossless PNG with longest edge `L` and
   the original aspect ratio.
2. Verify its dimensions and confirm that the file decodes successfully.
3. Deliver the file, a preview, and the prompts and settings used.
4. Describe added detail as reconstructed. Distinguish the exported resolution
   from the native generated resolution of the edited crops.
