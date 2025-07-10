import React from 'react';

// This component demonstrates accessibility issues that Copilot would detect
const ExampleComponent: React.FC = () => {
  const handleClick = () => {
    console.log('Button clicked');
  };

  return (
    <div>
      {/* ⚠️ ISSUE: Missing alt attribute - Copilot will flag this */}
      <img src="/logo.png" />
      
      {/* ⚠️ ISSUE: Form input without label - Copilot will flag this */}
      <input type="text" placeholder="Enter your name" />
      
      {/* ⚠️ ISSUE: Non-semantic element with click handler - Copilot will flag this */}
      <div onClick={handleClick} style={{ cursor: 'pointer' }}>
        Click me
      </div>
      
      {/* ⚠️ ISSUE: Poor heading hierarchy - Copilot will flag this */}
      <h1>Main Title</h1>
      <h3>Subtitle</h3> {/* Should be h2, not h3 */}
      <h2>Another Section</h2>
      
      {/* ⚠️ ISSUE: Color contrast - Copilot will flag this */}
      <p style={{ color: '#999999' }}>
        This text might have poor contrast
      </p>
      
      {/* ✅ GOOD: Proper form with labels */}
      <form>
        <label htmlFor="email">Email:</label>
        <input type="email" id="email" name="email" />
        
        <label htmlFor="message">Message:</label>
        <textarea id="message" name="message" />
      </form>
      
      {/* ✅ GOOD: Semantic button element */}
      <button onClick={handleClick}>
        Submit
      </button>
      
      {/* ✅ GOOD: Image with alt text */}
      <img src="/hero.jpg" alt="Hero image showing our product" />
    </div>
  );
};

export default ExampleComponent; 