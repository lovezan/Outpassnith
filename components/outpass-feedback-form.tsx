"use client"

import type React from "react"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Textarea } from "@/components/ui/textarea"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"
import { Label } from "@/components/ui/label"
import { ThumbsUp, ThumbsDown, Minus } from "lucide-react"
import { toast } from "@/components/ui/use-toast"

interface OutpassFeedbackFormProps {
  outpassId: string
  studentId: string
  onSuccess?: () => void
}

export function OutpassFeedbackForm({ outpassId, studentId, onSuccess }: OutpassFeedbackFormProps) {
  const [satisfactionLevel, setSatisfactionLevel] = useState<"dissatisfied" | "neutral" | "satisfied" | null>(null)
  const [feedbackText, setFeedbackText] = useState("")
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [isSubmitted, setIsSubmitted] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!satisfactionLevel) {
      toast({
        title: "Please select a satisfaction level",
        variant: "destructive",
      })
      return
    }

    if (!feedbackText.trim()) {
      toast({
        title: "Please provide feedback",
        description: "Your feedback helps us improve our services",
        variant: "destructive",
      })
      return
    }

    setIsSubmitting(true)

    try {
      const response = await fetch("/api/feedback", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          outpassId,
          studentId,
          satisfactionLevel,
          feedbackText,
        }),
      })

      if (!response.ok) {
        throw new Error("Failed to submit feedback")
      }

      setIsSubmitted(true)
      toast({
        title: "Feedback submitted",
        description: "Thank you for your feedback!",
      })

      if (onSuccess) {
        onSuccess()
      }
    } catch (error) {
      console.error("Error submitting feedback:", error)
      toast({
        title: "Failed to submit feedback",
        description: "Please try again later",
        variant: "destructive",
      })
    } finally {
      setIsSubmitting(false)
    }
  }

  if (isSubmitted) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Thank You!</CardTitle>
          <CardDescription>Your feedback has been submitted successfully.</CardDescription>
        </CardHeader>
        <CardContent>
          <p className="text-center text-muted-foreground">
            We appreciate your input and will use it to improve our services.
          </p>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card>
      <form onSubmit={handleSubmit}>
        <CardHeader>
          <CardTitle>Outpass Feedback</CardTitle>
          <CardDescription>Please share your feedback about the rejected outpass request</CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="space-y-2">
            <Label>How satisfied are you with the outpass process?</Label>
            <RadioGroup
              value={satisfactionLevel || ""}
              onValueChange={(value) => setSatisfactionLevel(value as "dissatisfied" | "neutral" | "satisfied")}
              className="flex justify-between"
            >
              <div className="flex flex-col items-center space-y-2">
                <Label
                  htmlFor="dissatisfied"
                  className={`flex h-16 w-16 cursor-pointer flex-col items-center justify-center rounded-md border-2 ${
                    satisfactionLevel === "dissatisfied" ? "border-red-500 bg-red-50" : "border-muted"
                  }`}
                >
                  <ThumbsDown
                    className={satisfactionLevel === "dissatisfied" ? "text-red-500" : "text-muted-foreground"}
                  />
                </Label>
                <RadioGroupItem value="dissatisfied" id="dissatisfied" className="sr-only" />
                <span className="text-xs">Dissatisfied</span>
              </div>

              <div className="flex flex-col items-center space-y-2">
                <Label
                  htmlFor="neutral"
                  className={`flex h-16 w-16 cursor-pointer flex-col items-center justify-center rounded-md border-2 ${
                    satisfactionLevel === "neutral" ? "border-yellow-500 bg-yellow-50" : "border-muted"
                  }`}
                >
                  <Minus className={satisfactionLevel === "neutral" ? "text-yellow-500" : "text-muted-foreground"} />
                </Label>
                <RadioGroupItem value="neutral" id="neutral" className="sr-only" />
                <span className="text-xs">Neutral</span>
              </div>

              <div className="flex flex-col items-center space-y-2">
                <Label
                  htmlFor="satisfied"
                  className={`flex h-16 w-16 cursor-pointer flex-col items-center justify-center rounded-md border-2 ${
                    satisfactionLevel === "satisfied" ? "border-green-500 bg-green-50" : "border-muted"
                  }`}
                >
                  <ThumbsUp
                    className={satisfactionLevel === "satisfied" ? "text-green-500" : "text-muted-foreground"}
                  />
                </Label>
                <RadioGroupItem value="satisfied" id="satisfied" className="sr-only" />
                <span className="text-xs">Satisfied</span>
              </div>
            </RadioGroup>
          </div>

          <div className="space-y-2">
            <Label htmlFor="feedback">Your feedback</Label>
            <Textarea
              id="feedback"
              placeholder="Please share your thoughts about the outpass process and why it was rejected..."
              value={feedbackText}
              onChange={(e) => setFeedbackText(e.target.value)}
              rows={5}
              className="resize-none"
            />
          </div>
        </CardContent>
        <CardFooter>
          <Button type="submit" disabled={isSubmitting} className="w-full">
            {isSubmitting ? "Submitting..." : "Submit Feedback"}
          </Button>
        </CardFooter>
      </form>
    </Card>
  )
}
