import React, { useState } from 'react';
import styled from 'styled-components';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import PhoneFrame from './components/PhoneFrame';
import IntroView from './components/IntroView';
import AuthenticationView from './components/AuthenticationView';
import NostalgicIntro from './components/NostalgicIntro';
import TutorialView from './components/TutorialView';
import CapsuleDashboard from './components/CapsuleDashboard';
import NewCapsuleView from './components/NewCapsuleView';
import CapsuleDetailView from './components/CapsuleDetailView';
import RecordingScreen from './components/RecordingScreen';
import UploadFlow from './components/UploadFlow';

const AppContainer = styled.div`
  width: 100vw;
  height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  justify-content: center;
  align-items: center;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
`;

const PreviewLabel = styled.div`
  position: absolute;
  top: 20px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 10px 20px;
  border-radius: 20px;
  font-size: 14px;
  z-index: 1000;
`;

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [currentView, setCurrentView] = useState('intro');

  const navigate = (view) => {
    console.log('Navigating to:', view); // Debug log
    setCurrentView(view);
  };

  const renderCurrentView = () => {
    console.log('Current view:', currentView); // Debug log
    switch (currentView) {
      case 'intro':
        return <IntroView onContinue={() => navigate('auth')} />;
      case 'auth':
        return <AuthenticationView onAuthenticate={() => {
          setIsAuthenticated(true);
          navigate('nostalgicIntro');
        }} />;
      case 'nostalgicIntro':
        return <NostalgicIntro onComplete={() => navigate('tutorial')} />;
      case 'tutorial':
        return <TutorialView onComplete={() => {
          console.log('Tutorial onComplete called, navigating to capsuleList');
          navigate('capsuleList');
        }} />;
      case 'capsuleList':
        return <CapsuleDashboard onNavigate={navigate} />;
      case 'newCapsule':
        return <NewCapsuleView onNavigate={navigate} />;
      case 'capsuleDetail':
        return <CapsuleDetailView onNavigate={navigate} />;
      case 'record':
        return <RecordingScreen onNavigate={navigate} />;
      case 'upload':
        return <UploadFlow onNavigate={navigate} />;
      default:
        return <IntroView onContinue={() => navigate('auth')} />;
    }
  };

  return (
    <AppContainer>
      <PreviewLabel>
        🎬 Time Capsule Camera - Live Preview
      </PreviewLabel>
      <PhoneFrame>
        {renderCurrentView()}
      </PhoneFrame>
    </AppContainer>
  );
}

export default App;