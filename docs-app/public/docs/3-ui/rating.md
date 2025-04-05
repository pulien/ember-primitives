# Rating

Ratings are used for displaying a score within a given range.

When interactive, the underlying implementation is a radio button for maximum accessibility.

<div class="featured-demo">

```gjs live preview
import { Rating } from 'ember-primitives';
import { cell } from 'ember-resources';

const capturedValue = cell(2);

<template>
  Current Value: {{capturedValue.current}}<br><hr>
  <Rating @value={{capturedValue.current}} @onChange={{capturedValue.set}}>
    <:label>Rate me</:label>
  </Rating>

  <style>
    @import "/demo-support/utilities.css";

    .ember-primitives__rating__items {
      width: fit-content;
      display: grid;
      gap: 0.5rem;
      grid-auto-flow: column;
      justify-content: center;
      align-items: center;
      height: 4rem;
    }

    .ember-primitives__rating__item {
      font-size: 3rem;
      line-height: 1em;
      transition: all 0.1s;
      transform-origin: center;
      aspect-ratio: 1 / 1;
      user-select: none;
      width: 3rem;
      text-align: center;
      border-radius: 1.5rem;

      label:hover {
        cursor: pointer;
      }

      &:has(input:focus-visible) {
        --tw-ring-opacity: 1;
        --tw-ring-offset-color: #000;
        --tw-ring-offset-width: 2px;
        --tw-ring-color: rgb(224 78 57 / var(--tw-ring-opacity, 1));
        --tw-ring-offset-shadow: var(--tw-ring-inset) 0 0 0 var(--tw-ring-offset-width) var(--tw-ring-offset-color);
        --tw-ring-shadow: var(--tw-ring-inset) 0 0 0 calc(2px + var(--tw-ring-offset-width)) var(--tw-ring-color);
        box-shadow: var(--tw-ring-offset-shadow), var(--tw-ring-shadow), var(--tw-shadow, 0 0 #0000);
        outline: 2px solid transparent;
        outline-offset: 2px;
      }

      input {
        appearance: none;
        position: absolute;

        &:focus-visible, &:focus {
          outline: none;
          box-shadow: none;
        }
      }

      &[data-selected] {
        color: gold;
      }
    } 

    .ember-primitives__rating__item:hover {
        transform: rotate3d(0, 0, 1, 15deg) scale(1.05);
    } 
  </style>
</template>
```

</div>

<details><summary>non-interactive (display-only) mode</summary>
<div class="featured-demo">

```gjs live preview 
import { Rating } from 'ember-primitives';

<template>
  <Rating @value={{2}} @interactive={{false}} />
  <Rating @value={{4}} @interactive={{false}}>
    <:label as |rating|>
      {{rating.value}} of {{rating.total}}
    </:label>
  </Rating>
  <Rating @value={{3}} @interactive={{false}} as |rating|>
    <rating.Stars />
    {{rating.value}} of {{rating.total}}
  </Rating>

  <style>
    @import "/demo-support/utilities.css";

    .ember-primitives__rating {
      width: fit-content;
      display: grid;
      gap: 0.5rem;
      grid-auto-flow: column;
      justify-content: center;
      align-items: center;
      height: 4rem;
    }

    .ember-primitives__rating__item {
        font-size: 3rem;
        line-height: 3rem;
        transition: all 0.1s;
        transform-origin: center;
        aspect-ratio: 1 / 1;
        cursor: pointer;
        user-select: none;

      input {
          display: none;
      }

      &[data-selected] {
        color: gold;
      }
    } 

    .ember-primitives__rating__item:hover {
        transform: rotate3d(0, 0, 1, 15deg) scale(1.05);
    } 
  </style>
</template>
```

</div>
</details>
<details><summary>Custom Component / Icons</summary>
<div class="featured-demo">

```gjs live preview 
import { Rating } from 'ember-primitives';

const Icon = <template>
  <div ...attributes style={{if @isSelected "transform:rotate(180deg)"}}>
    {{@value}}
  </div>
</template>;


<template>
  <Rating @icon={{Icon}} />

  <style>
    @import "/demo-support/utilities.css";

    .ember-primitives__rating__items {
      width: fit-content;
      display: grid;
      gap: 0.5rem;
      grid-auto-flow: column;
      justify-content: center;
      align-items: center;
      height: 4rem;
    }

    .ember-primitives__rating__item {
      font-size: 3rem;
      line-height: 1em;
      transition: all 0.1s;
      transform-origin: center;
      aspect-ratio: 1 / 1;
      user-select: none;
      width: 3rem;
      text-align: center;
      border-radius: 1.5rem;

      label:hover {
        cursor: pointer;
      }

      &:has(input:focus-visible) {
        --tw-ring-opacity: 1;
        --tw-ring-offset-color: #000;
        --tw-ring-offset-width: 2px;
        --tw-ring-color: rgb(224 78 57 / var(--tw-ring-opacity, 1));
        --tw-ring-offset-shadow: var(--tw-ring-inset) 0 0 0 var(--tw-ring-offset-width) var(--tw-ring-offset-color);
        --tw-ring-shadow: var(--tw-ring-inset) 0 0 0 calc(2px + var(--tw-ring-offset-width)) var(--tw-ring-color);
        box-shadow: var(--tw-ring-offset-shadow), var(--tw-ring-shadow), var(--tw-shadow, 0 0 #0000);
        outline: 2px solid transparent;
        outline-offset: 2px;
      }

      input {
        appearance: none;
        position: absolute;

        &:focus-visible, &:focus {
          outline: none;
          box-shadow: none;
        }
      }

      &[data-selected] {
        color: gold;
      }
    } 

    .ember-primitives__rating__item:hover {
        transform: rotate3d(0, 0, 1, 15deg) scale(1.05);
    } 
    </style>
</template>
```

</div>
</details>
<details><summary>No Styles</summary>
<div class="featured-demo">

```gjs live preview
import { Rating } from 'ember-primitives';

const Star = <template>
    <div class="item">
        <span class="icon">★</span>
    </div>
  </template>;

<template>
  <Rating as |rating|>
    {{rating.value}} of {{rating.total}}<br>
    <rating.Stars @icon={{Star}} />
  </Rating>

  <style>
    /* just layout, since we don't want to use all the vertical space */
    .ember-primitives__rating__items {
      display: flex;
      gap: 1rem;
    }
  </style>
</template>
```

</div>
</details>

## Features

- Any shape can be used
- All styles / directions possible via CSS
- Full componets can be passed for the rating items / stars, and will have all the same information is available (properties, state, etc). This allows for custom icons, svgs, or some more complex pattern.

## Accessibility

Keyboard users can always change the star rating as every variant of the component has individually selectable elements.

Screen reader users will have a summary of the state of the component read to them as "Rated $Current of $Total"

### Keyboard

Using this component works the same as a radio group. 
- Tab to focus the group as a whole
- Arrow keys to select
- Space toggles

## Testing

```gts
import * as primitiveHelpers from 'ember-primitives/test-support';

const rating = primitiveHelpers.rating();


test('example', async function (assert) {
  await render(
    <template>
      <Rating />
    </template>
  );

  assert.strictEqual(rating.value, 0);
  assert.strictEqual(rating.isReadonly, false);

  await rating.select(3);
  assert.strictEqual(rating.value, 3);
  assert.strictEqual(rating.stars, '★ ★ ★ ☆ ☆');

  // Toggle
  await rating.select(3);
  assert.strictEqual(rating.value, 0);
  assert.strictEqual(rating.stars, '☆ ☆ ☆ ☆ ☆');
});
```

<details><summary>Multiple on a page</summary>

```gts
test('multiple', async function (assert) {
  await render(
    <template>
      <Rating data-test-first />
      <Rating data-test-second />
    </template>
  );

  const first = createTestHelper('[data-test-first]');
  const second = createTestHelper('[data-test-second]');

  assert.strictEqual(first.value, 0, 'first Rating has no selection');
  assert.strictEqual(second.value, 0, 'second Rating has no selection');

  await first.select(3);
  assert.strictEqual(first.value, 3, 'first Rating now has 3 stars');
  assert.strictEqual(second.value, 0, 'second Rating is still unchanged');

  await second.select(4);
  assert.strictEqual(second.value, 4, 'second Rating now has 4 stars');
  assert.strictEqual(first.value, 3, 'first Rating is still unchanged (at 3)');

  // Toggle First
  await first.select(3);
  assert.strictEqual(first.value, 0, 'first Rating is toggled from 3 to 0');
  assert.strictEqual(second.value, 4, 'second Rating is still unchanged (at 4)');

  // Toggle Second
  await second.select(4);
  assert.strictEqual(second.value, 0, 'second Rating is toggled from 4 to 0');
  assert.strictEqual(first.value, 0, 'first Rating is still unchanged (at 0)');
});
```

</details>



## API Reference

```gjs live no-shadow
import { ComponentSignature } from 'kolay';

<template>
  <ComponentSignature 
    @package="ember-primitives" 
    @module="declarations/components/rating" 
    @name="Rating" />
</template>
```

### Classes & Attributes

All these classes do nothing on their own, but offer a way for folks authoring CSS to set their styles. 

- `.ember-primitives__rating`

    This is the class on the root-level element, the `<fieldset>`. This element has some data attributes representing the overall state of the rating component. 

    - `[data-total]` number.
    - `[data-value]` number.
    - `[data-readonly]` boolean.


- `.ember-primitives__rating__items`

    The wrapping element around all of the individual items (stars by default). This is placed on a `div`.

- `.ember-primitives__rating__item`

    Each item (star by default) is wrapped in a `span` with tihs class. This element also has the some data-attributes representing the state of an individual item / star. 

    - `[data-number]` number. Which numer of the total this item is.
    - `[data-selected]` boolean.
    - `[data-readonly]` boolean.
    - `[data-disabled]` boolean.

    Every item underneath this element with the `*item` class has unique elements or other selectors. Generally DOM is private API for JavaScript access, but styling with CSS may need access to both the `label` and the `input`.

- `.ember-primitives__rating__label`

    This is the class used by default when no `<:label>` block/slot is provided. It says "Rated $Value of $Total", but is visually hidden, as sighted users can see the star rating visuals. This class is not used for any other reason. 

