import React, { useState } from 'react';
import styled from 'styled-components';
import { motion } from 'framer-motion';

const Container = styled.div`
  padding: 20px;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
`;

const Header = styled.div`
  display: flex;
  align-items: center;
  margin-bottom: 30px;
`;

const BackButton = styled.button`
  background: none;
  border: none;
  color: white;
  font-size: 18px;
  cursor: pointer;
  margin-right: 16px;
`;

const Title = styled.h1`
  color: white;
  font-size: 24px;
  font-weight: 700;
  margin: 0;
`;

const Form = styled.form`
  display: flex;
  flex-direction: column;
  gap: 20px;
`;

const InputGroup = styled.div`
  display: flex;
  flex-direction: column;
  gap: 8px;
`;

const Label = styled.label`
  color: white;
  font-size: 16px;
  font-weight: 600;
`;

const Input = styled.input`
  padding: 16px;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  color: white;
  font-size: 16px;
  
  &::placeholder {
    color: rgba(255, 255, 255, 0.6);
  }
  
  &:focus {
    outline: none;
    border-color: rgba(255, 255, 255, 0.4);
    background: rgba(255, 255, 255, 0.15);
  }
`;

const TextArea = styled.textarea`
  padding: 16px;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  color: white;
  font-size: 16px;
  min-height: 80px;
  resize: none;
  font-family: inherit;
  
  &::placeholder {
    color: rgba(255, 255, 255, 0.6);
  }
  
  &:focus {
    outline: none;
    border-color: rgba(255, 255, 255, 0.4);
    background: rgba(255, 255, 255, 0.15);
  }
`;

const DateInfo = styled.div`
  background: rgba(255, 255, 255, 0.1);
  padding: 16px;
  border-radius: 12px;
  color: rgba(255, 255, 255, 0.8);
  font-size: 14px;
`;

const ButtonGroup = styled.div`
  display: flex;
  gap: 12px;
  margin-top: 20px;
`;

const Button = styled(motion.button)`
  flex: 1;
  padding: 16px;
  border: none;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  
  &.primary {
    background: rgba(255, 255, 255, 0.9);
    color: #4c63d2;
  }
  
  &.secondary {
    background: rgba(255, 255, 255, 0.2);
    color: white;
  }
`;

const NewCapsuleView = ({ onNavigate }) => {
  const [capsuleName, setCapsuleName] = useState('');
  const [description, setDescription] = useState('');
  const [unsealDate, setUnsealDate] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    // Simulate creating capsule
    setTimeout(() => {
      onNavigate('capsuleList');
    }, 1000);
  };

  const calculateDaysUntil = (date) => {
    if (!date) return 0;
    const targetDate = new Date(date);
    const today = new Date();
    const diffTime = targetDate - today;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return Math.max(0, diffDays);
  };

  return (
    <Container>
      <Header>
        <BackButton onClick={() => onNavigate('capsuleList')}>
          ←
        </BackButton>
        <Title>New Capsule</Title>
      </Header>
      
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
      >
        <Form onSubmit={handleSubmit}>
          <InputGroup>
            <Label>Capsule Name</Label>
            <Input
              type="text"
              placeholder="Give your capsule a name..."
              value={capsuleName}
              onChange={(e) => setCapsuleName(e.target.value)}
              required
            />
          </InputGroup>
          
          <InputGroup>
            <Label>Description (Optional)</Label>
            <TextArea
              placeholder="What's this capsule about?"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
            />
          </InputGroup>
          
          <InputGroup>
            <Label>Unseal Date</Label>
            <Input
              type="date"
              value={unsealDate}
              onChange={(e) => setUnsealDate(e.target.value)}
              min={new Date().toISOString().split('T')[0]}
              required
            />
            {unsealDate && (
              <DateInfo>
                📅 This capsule will automatically unseal in {calculateDaysUntil(unsealDate)} days
              </DateInfo>
            )}
          </InputGroup>
          
          <ButtonGroup>
            <Button
              type="button"
              className="secondary"
              onClick={() => onNavigate('capsuleList')}
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              className="primary"
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
            >
              Create Capsule
            </Button>
          </ButtonGroup>
        </Form>
      </motion.div>
    </Container>
  );
};

export default NewCapsuleView;