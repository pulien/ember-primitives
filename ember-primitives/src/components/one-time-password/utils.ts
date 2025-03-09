import { assert } from '@ember/debug';

function getInputs(current: HTMLInputElement) {
  const fieldset = current.closest('fieldset');

  assert('[BUG]: fieldset went missing', fieldset);

  return [...fieldset.querySelectorAll('input')];
}

function nextInput(current: HTMLInputElement) {
  const inputs = getInputs(current);
  const currentIndex = inputs.indexOf(current);

  return inputs[currentIndex + 1];
}

export function selectAll(event: Event) {
  const target = event.target;

  assert(`selectAll is only meant for use with input elements`, target instanceof HTMLInputElement);

  target.select();
}

export function handlePaste(event: Event) {
  const target = event.target;

  assert(
    `handlePaste is only meant for use with input elements`,
    target instanceof HTMLInputElement
  );

  const clipboardData = (event as ClipboardEvent).clipboardData;

  assert(
    `Could not get clipboardData while handling the paste event on OTP. Please report this issue on the ember-primitives repo with a reproduction. Thanks!`,
    clipboardData
  );

  // This is typically not good to prevent paste.
  // But because of the UX we're implementing,
  // we want to split the pasted value across
  // multiple text fields
  event.preventDefault();

  const value = clipboardData.getData('Text');
  const digits = value;
  let i = 0;
  let currElement: HTMLInputElement | null = target;

  while (currElement) {
    currElement.value = digits[i++] || '';

    const next = nextInput(currElement);

    if (next instanceof HTMLInputElement) {
      currElement = next;
    } else {
      break;
    }
  }

  // We want to select the first field again
  // so that if someone holds paste, or
  // pastes again, they get the same result.
  target.select();
}

export function handleNavigation(event: KeyboardEvent) {
  switch (event.key) {
    case 'Backspace':
      return handleBackspace(event);
    case 'ArrowLeft':
      return focusLeft(event);
    case 'ArrowRight':
      return focusRight(event);
  }
}

function focusLeft(event: Pick<Event, 'target'>) {
  const target = event.target;

  assert(`only allowed on input elements`, target instanceof HTMLInputElement);

  const input = previousInput(target);

  input?.focus();
  requestAnimationFrame(() => {
    input?.select();
  });
}

function focusRight(event: Pick<Event, 'target'>) {
  const target = event.target;

  assert(`only allowed on input elements`, target instanceof HTMLInputElement);

  const input = nextInput(target);

  input?.focus();
  requestAnimationFrame(() => {
    input?.select();
  });
}

const syntheticEvent = new InputEvent('input');

function handleBackspace(event: KeyboardEvent) {
  if (event.key !== 'Backspace') return;

  /**
   * We have to prevent default because we
   * - want to clear the whole field
   * - have the focus behavior keep up with the key-repeat
   *   speed of the user's computer
   */
  event.preventDefault();

  const target = event.target;

  if (target && 'value' in target) {
    if (target.value === '') {
      focusLeft({ target });
    } else {
      target.value = '';
    }
  }

  target?.dispatchEvent(syntheticEvent);
}

function previousInput(current: HTMLInputElement) {
  const inputs = getInputs(current);
  const currentIndex = inputs.indexOf(current);

  return inputs[currentIndex - 1];
}

export const autoAdvance = (event: Event) => {
  assert(
    '[BUG]: autoAdvance called on non-input element',
    event.target instanceof HTMLInputElement
  );

  const value = event.target.value;

  if (value.length === 0) return;

  if (value.length > 0) {
    if ('data' in event && event.data && typeof event.data === 'string') {
      event.target.value = event.data;
    }

    return focusRight(event);
  }
};

export function getCollectiveValue(elementTarget: EventTarget | null, length: number) {
  if (!elementTarget) return;

  assert(
    `[BUG]: somehow the element target is not HTMLElement`,
    elementTarget instanceof HTMLElement
  );

  let parent: null | HTMLElement | ShadowRoot;

  // TODO: should this logic be extracted?
  //       why is getting the target element within a shadow root hard?
  if (!(elementTarget instanceof HTMLInputElement)) {
    if (elementTarget.shadowRoot) {
      parent = elementTarget.shadowRoot;
    } else {
      parent = elementTarget.closest('fieldset');
    }
  } else {
    parent = elementTarget.closest('fieldset');
  }

  assert(`[BUG]: somehow the input fields were rendered without a parent element`, parent);

  const elements = parent.querySelectorAll('input');

  let value = '';

  assert(
    `found elements (${elements.length}) do not match length (${length}). Was the same OTP input rendered more than once?`,
    elements.length === length
  );

  for (const element of elements) {
    assert(
      '[BUG]: how did the queried elements become a non-input element?',
      element instanceof HTMLInputElement
    );
    value += element.value;
  }

  return value;
}
